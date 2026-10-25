import { Outlet } from 'react-router-dom';

/** Admin root layout – sidebar, header, breadcrumb */
export default function AdminRoot() {
  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="w-64 border-r bg-gray-50">
        <nav className="p-4">
          {/* TODO: Sidebar menu komponens */}
        </nav>
      </aside>

      {/* Fo tartalom */}
      <div className="flex-1">
        <header className="border-b px-6 py-4">
          {/* TODO: Header + breadcrumb */}
        </header>
        <main className="p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
