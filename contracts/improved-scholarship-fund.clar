;; Constants
(define-constant err-not-owner (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-applied (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-application-closed (err u104))
(define-constant err-arithmetic-error (err u105))
(define-constant err-invalid-amount (err u106))
(define-constant err-invalid-reason (err u107))
(define-constant err-invalid-principal (err u108))
(define-constant err-invalid-category (err u109))
(define-constant err-invalid-date (err u110))
(define-constant err-past-deadline (err u111))
(define-constant err-invalid-score (err u112))
(define-constant err-invalid-round (err u113))
(define-constant err-student-not-applied (err u114))

;; Variables
(define-data-var current-round-id uint u0)
(define-data-var owner principal tx-sender)

;; Data Maps
(define-map scholarship-rounds 
  { round-id: uint } 
  { 
    start-date: uint, 
    end-date: uint, 
    total-fund: uint, 
    status: (string-ascii 10) 
  }
)
(define-map application-scores 
  { round-id: uint, student: principal } 
  { score: uint }
)
(define-map applicants 
  { student: principal } 
  { 
    status: (string-ascii 10), 
    amount-requested: uint, 
    reason: (string-utf8 500) 
  }
)

;; Private Functions
(define-private (is-owner)
  (is-eq tx-sender (var-get owner))
)

(define-private (is-valid-round (round-id uint))
  (is-some (map-get? scholarship-rounds { round-id: round-id }))
)

(define-private (has-student-applied (student principal))
  (is-some (map-get? applicants { student: student }))
)

(define-public (create-scholarship-round (start-date uint) (end-date uint) (initial-fund uint))
  (begin
    (asserts! (is-owner) err-not-owner)
    (asserts! (and (> start-date block-height) (> end-date start-date)) err-invalid-date)
    (asserts! (> initial-fund u0) err-invalid-amount)
    (let
      (
        (new-round-id (+ (var-get current-round-id) u1))
      )
      (try! (stx-transfer? initial-fund tx-sender (as-contract tx-sender)))
      
      (map-set scholarship-rounds
        { round-id: new-round-id }
        { start-date: start-date, end-date: end-date, total-fund: initial-fund, status: "active" }
      )
      (var-set current-round-id new-round-id)
      (ok new-round-id)
    )
  )
)

(define-public (apply-scholarship-in-round (round-id uint) (amount-requested uint) (reason (string-utf8 500)))
  (let
    (
      (round (unwrap! (map-get? scholarship-rounds { round-id: round-id }) err-not-found))
    )
    (asserts! (> amount-requested u0) err-invalid-amount)
    (asserts! (> (len reason) u0) err-invalid-reason)
    (asserts! (is-eq (get status round) "active") err-application-closed)
    (asserts! (<= block-height (get end-date round)) err-past-deadline)
    (asserts! (is-none (map-get? applicants { student: tx-sender })) err-already-applied)
    (ok (map-set applicants
      { student: tx-sender }
      { status: "pending", amount-requested: amount-requested, reason: reason }
    ))
  )
)

(define-public (score-application (round-id uint) (student principal) (score uint))
  (begin
    (asserts! (is-valid-round round-id) err-invalid-round)
    (asserts! (and (>= score u0) (<= score u100)) err-invalid-score)
    (asserts! (has-student-applied student) err-student-not-applied)
    
    (ok (map-set application-scores
      { round-id: round-id, student: student }
      { score: score }
    ))
  )
)

(define-public (finalize-scholarship-round (round-id uint))
  (begin
    (asserts! (is-valid-round round-id) err-invalid-round)
    (let
      (
        (round (unwrap! (map-get? scholarship-rounds { round-id: round-id }) err-not-found))
      )
      (asserts! (> block-height (get end-date round)) err-invalid-date)
      (asserts! (is-eq (get status round) "active") err-application-closed)
      
      (ok (map-set scholarship-rounds
        { round-id: round-id }
        (merge round { status: "finalized" })
      ))
    )
  )
)

(define-read-only (get-scholarship-round (round-id uint))
  (ok (unwrap! (map-get? scholarship-rounds { round-id: round-id }) err-not-found))
)

(define-read-only (get-application-score (round-id uint) (student principal))
  (ok (unwrap! (map-get? application-scores { round-id: round-id, student: student }) err-not-found))
)

(define-read-only (get-current-round-id)
  (ok (var-get current-round-id))
)