;; Decentralized Scholarship Fund
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

;; Fungible Token for donations
(define-fungible-token scholarship-token)

;; Data Maps
(define-map donors { donor: principal } { total-donated: uint })
(define-map applicants { student: principal } { status: (string-ascii 10), amount-requested: uint, reason: (string-utf8 500) })

;; Variables
(define-data-var total-scholarship-fund uint u0)
(define-data-var owner principal tx-sender)

;; Private Function to Check Owner
(define-private (is-owner)
  (is-eq tx-sender (var-get owner))
)

;; Private Function to Safely Add Uint
(define-private (safe-add (a uint) (b uint))
  (let ((result (+ a b)))
    (if (< result a)
      err-arithmetic-error
      (ok result))
  )
)

;; Private Function to Validate Amount
(define-private (validate-amount (amount uint))
  (> amount u0)
)

;; Private Function to Validate Reason
(define-private (validate-reason (reason (string-utf8 500)))
  (and (> (len reason) u0) (<= (len reason) u500))
)

;; Private Function to Validate Principal
(define-private (validate-principal (principal-input principal))
  ;; Simple check to ensure the principal is valid
  (is-eq principal-input principal-input)
)

;; Public Function: Donate to Scholarship Fund
(define-public (donate (amount uint))
  (begin
    (asserts! (validate-amount amount) err-invalid-amount)
    (try! (ft-transfer? scholarship-token amount tx-sender (var-get owner)))
    (let ((existing-donation (map-get? donors { donor: tx-sender })))
      (if (is-some existing-donation)
        (let (
          (donation-data (unwrap-panic existing-donation))
          (new-total (try! (safe-add (get total-donated donation-data) amount)))
        )
          (map-set donors 
            { donor: tx-sender } 
            { total-donated: new-total }))
        (map-set donors { donor: tx-sender } { total-donated: amount })))
    (let ((new-fund (try! (safe-add (var-get total-scholarship-fund) amount))))
      (var-set total-scholarship-fund new-fund)
      (ok true))
  )
)

;; Public Function: Apply for Scholarship
(define-public (apply-scholarship (amount-requested uint) (reason (string-utf8 500)))
  (begin
    (asserts! (validate-amount amount-requested) err-invalid-amount)
    (asserts! (validate-reason reason) err-invalid-reason)
    ;; Ensure application is not closed
    (asserts! (> (var-get total-scholarship-fund) u0) err-application-closed)
    ;; Check if the applicant has already applied
    (let ((existing-application (map-get? applicants { student: tx-sender })))
      (asserts! (is-none existing-application) err-already-applied)
      ;; Apply for scholarship
      (map-set applicants 
        { student: tx-sender } 
        { status: "pending", amount-requested: amount-requested, reason: reason })
      (ok true)
    )
  )
)

;; Public Function: Approve or Reject Application
(define-public (evaluate-application (student principal) (approve bool))
  (begin
    (asserts! (is-owner) err-not-owner)
    ;; Validate student principal
    (asserts! (validate-principal student) err-invalid-principal)
    ;; Check if the application exists
    (let ((application (map-get? applicants { student: student })))
      (asserts! (is-some application) err-not-found)
      (let ((application-data (unwrap! application err-not-found)))
        (if approve
          (begin
            (let ((requested (get amount-requested application-data)))
              (asserts! (>= (var-get total-scholarship-fund) requested) err-insufficient-funds)
              ;; Transfer tokens to student and update fund
              (try! (ft-transfer? scholarship-token requested (var-get owner) student))
              (map-set applicants
                { student: student }
                { status: "approved", amount-requested: requested, reason: (get reason application-data) }
              )
              (var-set total-scholarship-fund (- (var-get total-scholarship-fund) requested))
              (ok true)
            )
          )
          (begin
            ;; If rejected, update status
            (map-set applicants
              { student: student }
              { status: "rejected", amount-requested: (get amount-requested application-data), reason: (get reason application-data) }
            )
            (ok false)
          )
        )
      )
    )
  )
)

;; Public Function: Get Application Status
(define-read-only (get-application-status (student principal))
  (match (map-get? applicants { student: student })
    application (ok (get status application))
    (err err-not-found)
  )
)

;; Public Function: Get Total Fund Available
(define-read-only (get-total-fund)
  (ok (var-get total-scholarship-fund))
)

;; New constant for maximum category length
(define-constant max-category-length u50)

;; New data map for earmarked funds
(define-map earmarked-funds { category: (string-ascii 50) } { amount: uint })

;; New data map for donor earmarks
(define-map donor-earmarks { donor: principal, category: (string-ascii 50) } { amount: uint })

;; Private function to validate category
(define-private (validate-category (category (string-ascii 50)))
  (and (> (len category) u0) (<= (len category) max-category-length))
)

;; Public function to donate with earmark
(define-public (donate-earmarked (amount uint) (category (string-ascii 50)))
  (begin
    (asserts! (validate-amount amount) err-invalid-amount)
    (asserts! (validate-category category) (err u109)) ;; New error code for invalid category
    (try! (ft-transfer? scholarship-token amount tx-sender (var-get owner)))
    ;; Update donor's total donation
    (let ((existing-donation (map-get? donors { donor: tx-sender })))
      (if (is-some existing-donation)
        (let (
          (donation-data (unwrap-panic existing-donation))
          (new-total (try! (safe-add (get total-donated donation-data) amount)))
        )
          (map-set donors 
            { donor: tx-sender } 
            { total-donated: new-total }))
        (map-set donors { donor: tx-sender } { total-donated: amount })))
    
    ;; Update earmarked funds
    (let ((existing-earmark (map-get? earmarked-funds { category: category })))
      (if (is-some existing-earmark)
        (let (
          (earmark-data (unwrap-panic existing-earmark))
          (new-amount (try! (safe-add (get amount earmark-data) amount)))
        )
          (map-set earmarked-funds 
            { category: category } 
            { amount: new-amount }))
        (map-set earmarked-funds { category: category } { amount: amount })))
    
    ;; Update donor's earmarks
    (let ((existing-donor-earmark (map-get? donor-earmarks { donor: tx-sender, category: category })))
      (if (is-some existing-donor-earmark)
        (let (
          (donor-earmark-data (unwrap-panic existing-donor-earmark))
          (new-amount (try! (safe-add (get amount donor-earmark-data) amount)))
        )
          (map-set donor-earmarks 
            { donor: tx-sender, category: category } 
            { amount: new-amount }))
        (map-set donor-earmarks { donor: tx-sender, category: category } { amount: amount })))
    
    ;; Update total scholarship fund
    (let ((new-fund (try! (safe-add (var-get total-scholarship-fund) amount))))
      (var-set total-scholarship-fund new-fund)
      (ok true))
  )
)

;; Public read-only function to get earmarked amount for a category
(define-read-only (get-earmarked-amount (category (string-ascii 50)))
  (match (map-get? earmarked-funds { category: category })
    earmark (ok (get amount earmark))
    (err err-not-found)
  )
)

;; Public read-only function to get donor's earmarked amount for a category
(define-read-only (get-donor-earmarked-amount (donor principal) (category (string-ascii 50)))
  (match (map-get? donor-earmarks { donor: donor, category: category })
    earmark (ok (get amount earmark))
    (err err-not-found)
  )
)
