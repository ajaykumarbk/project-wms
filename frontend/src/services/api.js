import axios from 'axios';

const api = axios.create({
  // ✅ SAME-DOMAIN API (NO CORS EVER)
  baseURL: '/api',

  // Optional but recommended
  withCredentials: true,

  headers: {
    'Content-Type': 'application/json'
  }
});

export default api;

