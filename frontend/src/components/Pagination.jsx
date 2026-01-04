export default function Pagination({ page, pages, onPageChange }) {
    return (
      <div className="pagination">
        <button onClick={() => onPageChange(page - 1)} disabled={page <= 1}>Previous</button>
        <span>Page {page} of {pages}</span>
        <button onClick={() => onPageChange(page + 1)} disabled={page >= pages}>Next</button>
      </div>
    )
  }