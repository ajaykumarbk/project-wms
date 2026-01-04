import { useState, useEffect, useContext } from 'react';
import { AuthContext } from '../context/AuthContext';
import api from '../services/api';
import { Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

export default function AnalyticsDashboard() {
  const { user } = useContext(AuthContext);
  const [data, setData] = useState(null);

  useEffect(() => {
    if (user?.role === 'admin') {
      // ✅ SAME-DOMAIN API CALL
      api.get('/analytics')
        .then(res => setData(res.data))
        .catch(err => console.error('Analytics error:', err));
    }
  }, [user]);

  if (user?.role !== 'admin') return <p>Access denied.</p>;
  if (!data) return <p>Loading analytics...</p>;

  const chartData = {
    labels: data.byCategory.map(c => c.name),
    datasets: [
      {
        label: 'Complaints',
        data: data.byCategory.map(c => c.count),
        backgroundColor: '#27ae60'
      }
    ]
  };

  return (
    <div>
      <h2>Analytics Dashboard</h2>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: '20px',
          marginBottom: '30px'
        }}
      >
        <div className="card">
          <h3>Total Complaints</h3>
          <p style={{ fontSize: '2rem' }}>{data.totalComplaints}</p>
        </div>

        <div className="card">
          <h3>Pending</h3>
          <p style={{ fontSize: '2rem', color: '#f39c12' }}>
            {data.pending}
          </p>
        </div>

        <div className="card">
          <h3>Resolved</h3>
          <p style={{ fontSize: '2rem', color: '#27ae60' }}>
            {data.resolved}
          </p>
        </div>

        <div className="card">
          <h3>Users</h3>
          <p style={{ fontSize: '2rem' }}>{data.users}</p>
        </div>
      </div>

      <div className="card">
        <h3>Complaints by Category</h3>
        <Bar data={chartData} />
      </div>
    </div>
  );
}
