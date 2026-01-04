export default function ComplaintCard({ complaint, onStatusChange }) {
    const statusColor = {
      pending: '#f39c12',
      in_progress: '#3498db',
      resolved: '#27ae60'
    }
  
    return (
      <div className="card">
        <h3>{complaint.title}</h3>
        <p>{complaint.description}</p>
        <p><strong>Category:</strong> {complaint.category_name}</p>
        <p><strong>Location:</strong> {complaint.latitude}, {complaint.longitude}</p>
        {complaint.image_url && (
          <img src={complaint.image_url} alt="Complaint" style={{ maxWidth: '300px', margin: '10px 0' }} />
        )}
        <p>
          <strong>Status:</strong>
          <span style={{ color: statusColor[complaint.status], marginLeft: '8px' }}>
            {complaint.status.replace('_', ' ').toUpperCase()}
          </span>
        </p>
        {onStatusChange && (
          <select
            defaultValue={complaint.status}
            onChange={(e) => onStatusChange(complaint.id, e.target.value)}
            style={{ marginTop: '10px' }}
          >
            <option value="pending">Pending</option>
            <option value="in_progress">In Progress</option>
            <option value="resolved">Resolved</option>
          </select>
        )}
      </div>
    )
  }