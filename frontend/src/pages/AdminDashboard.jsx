import { useState, useEffect, useContext } from 'react';
import { AuthContext } from '../context/AuthContext';
import ComplaintCard from '../components/ComplaintCard';
import api from '../services/api';
import { io } from 'socket.io-client';

export default function AdminDashboard() {
  const { user } = useContext(AuthContext);
  const [complaints, setComplaints] = useState([]);

  useEffect(() => {
    if (user?.role !== 'admin') return;

    // ✅ SAME-DOMAIN API CALL
    api.get('/complaints')
      .then(res => setComplaints(res.data.complaints))
      .catch(err => console.error('Failed to load complaints', err));

    // ✅ SAME-DOMAIN SOCKET.IO (NO URL = SAME ORIGIN)
    const socket = io({
      path: '/socket.io',
      transports: ['websocket', 'polling'],
      secure: true
    });

    socket.on('complaintAdded', (c) =>
      setComplaints(prev => [c, ...prev])
    );

    socket.on('statusUpdated', (c) =>
      setComplaints(prev =>
        prev.map(p => (p.id === c.id ? c : p))
      )
    );

    return () => socket.disconnect();
  }, [user]);

  // ✅ SAME-DOMAIN STATUS UPDATE
  const updateStatus = (id, status) => {
    api.patch(`/complaints/${id}/status`, { status })
      .catch(err => console.error('Status update failed', err));
  };

  if (user?.role !== 'admin') {
    return <p>Access denied.</p>;
  }

  return (
    <div>
      <h2>Admin Panel</h2>
      {complaints.map(c => (
        <ComplaintCard
          key={c.id}
          complaint={c}
          onStatusChange={updateStatus}
        />
      ))}
    </div>
  );
}
