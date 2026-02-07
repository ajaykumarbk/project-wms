import { useContext } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { AuthContext } from '../context/AuthContext'

export default function Navbar() {
  const { user, logout } = useContext(AuthContext)
  const navigate = useNavigate()

  return (
    <nav className="navbar">
      <Link to="/" style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>WMS</Link>
      <div>
        {user ? (
          <>
            <Link to="/report">Report</Link>
            <Link to="/my-complaints">My Reports</Link>
            {user.role === 'admin' && <Link to="/admin">Admin</Link>}
            <Link to="/tips">Tips</Link>
            {user.role === 'admin' && <Link to="/analytics">Analytics</Link>}
            <button onClick={() => { logout(); navigate('/') }}>Logout</button>
          </>
        ) : (
          <>
            <Link to="/login">Login</Link>
            <Link to="/register">Register</Link>
          </>
        )}
      </div>
    </nav>
  )
}