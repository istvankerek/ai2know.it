/** Export/Delete/Edit/Download bulk muvelet gombok */
interface BulkActionsProps { selectedCount: number; }

export default function BulkActions({ selectedCount }: BulkActionsProps) {
  if (selectedCount === 0) return null;
  return (
    <div className="flex gap-2 p-2 bg-blue-50 rounded">
      <span>{selectedCount} kijelolve</span>
      <button>Export</button>
      <button>Szerkesztes</button>
      <button>Torles</button>
    </div>
  );
}
