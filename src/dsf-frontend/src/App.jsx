// import reactLogo from './assets/react.svg'
// import viteLogo from '/vite.svg'
// import './App.css'
import Navbar from '../src/components/Navbar'
import './index.css';
// import '../src/components/Slider'
import Slider from '../src/components/Slider';

function App() {

  return (
    <div className='bg-black'>
      <Navbar />
     <div className='mt-40'>
      <Slider />
        </div>
    </div>
  )
}

export default App
