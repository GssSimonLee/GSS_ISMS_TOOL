import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import VMSection from './components/VMSection'
import GitSection from './components/GitSection'
import './App.css'

function App() {
  return (
    <div>
      { /* Header */}
      <header className='bg-primary text-white py-3'>
        <div className='container'>
          <h1 className='text-center'>React App</h1>
        </div>
      </header>

      { /* Main */}
      <main className='container my-4'>
        <div className='row'>
          <div className='col'>
            <h2>ISMS Report Generate Tools</h2>
            <VMSection />
            <GitSection />
          </div>
        </div>
      </main>
      { /* Footer */}
      <footer className='bg-light text-center py-3 border-top'>
        <p className='mb-0'>@ GSS</p>
      </footer>
    </div>
  )
}

export default App
