import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Navbar from './components/Navbar'
import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import ReportComplaint from './pages/ReportComplaint'
import MyComplaints from './pages/MyComplaints'
import AdminDashboard from './pages/AdminDashboard'
import RecyclingTips from './pages/RecyclingTips'
import AnalyticsDashboard from './pages/AnalyticsDashboard'

function App() {
  return (
    <BrowserRouter>
      <Navbar />
      <div className="container">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/report" element={<ReportComplaint />} />
          <Route path="/my-complaints" element={<MyComplaints />} />
          <Route path="/admin" element={<AdminDashboard />} />
          <Route path="/tips" element={<RecyclingTips />} />
          <Route path="/analytics" element={<AnalyticsDashboard />} />
        </Routes>
      </div>
    </BrowserRouter>
  )
}

export default App