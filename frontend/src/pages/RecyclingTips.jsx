import { useState, useEffect } from 'react';
import Pagination from '../components/Pagination';
import api from '../services/api'; // ✅ shared API client

export default function RecyclingTips() {
  const [tips, setTips] = useState([]);
  const [page, setPage] = useState(1);
  const [pages, setPages] = useState(1);

  useEffect(() => {
    // ✅ SAME-DOMAIN API CALL
    api.get(`/tips?page=${page}`)
      .then(res => {
        setTips(res.data.tips);
        setPages(res.data.pages);
      })
      .catch(() => console.error('Failed to load tips'));
  }, [page]);

  return (
    <div>
      <h2>Recycling Tips</h2>

      {tips.map(tip => (
        <div key={tip.id} className="card">
          <h3>{tip.title}</h3>
          <p>{tip.content}</p>
        </div>
      ))}

      <Pagination page={page} pages={pages} onPageChange={setPage} />
    </div>
  );
}
