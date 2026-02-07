import { useState, useEffect, useContext } from 'react';
import { AuthContext } from '../context/AuthContext';
import ComplaintCard from '../components/ComplaintCard';
import Pagination from '../components/Pagination';
import api from '../services/api'; // ✅ shared API client

export default function MyComplaints() {
  const { user } = useContext(AuthContext);
  const [complaints, setComplaints] = useState([]);
  const [page, setPage] = useState(1);
  const [pages, setPages] = useState(1);

  useEffect(() => {
    if (!user) return;

    // ✅ SAME-DOMAIN API CALL
    api.get(`/complaints?page=${page}`)
      .then(res => {
        setComplaints(res.data.complaints);
        setPages(res.data.pages);
      })
      .catch(() => console.error('Failed to fetch complaints'));
  }, [page, user]);

  if (!user) return <p>Please login.</p>;

  return (
    <div>
      <h2>My Complaints</h2>

      {complaints.map(c => (
        <ComplaintCard key={c.id} complaint={c} />
      ))}

      <Pagination page={page} pages={pages} onPageChange={setPage} />
    </div>
  );
}
