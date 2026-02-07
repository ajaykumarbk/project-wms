import { useContext } from 'react'
import { AuthContext } from '../context/AuthContext'
import { Link } from 'react-router-dom'

export default function Home() {
  const { user } = useContext(AuthContext)

  return (
    <div style={{ textAlign: 'center', padding: '40px 0' }}>
      <h1>Waste Management System</h1>
      <p style={{ fontSize: '1.2rem', margin: '20px 0' }}>
        Report waste issues, track status, and learn recycling tips.
      </p>
      {!user ? (
        <>
          <Link to="/register"><button style={{ margin: '0 10px' }}>Get Started</button></Link>
          <Link to="/login"><button style={{ background: '#3498db' }}>Login</button></Link>
        </>
      ) : (
        <Link to="/report"><button>Report a Problem</button></Link>
      )}
    </div>
  )
}