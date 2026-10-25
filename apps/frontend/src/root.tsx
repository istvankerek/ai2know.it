import { Outlet } from 'react-router-dom';

/** Root layout – kozos elemek (header, footer) */
export default function Root() {
  return (
    <div className="min-h-screen">
      <header>{/* TODO: Header komponens */}</header>
      <main>
        <Outlet />
      </main>
      <footer>{/* TODO: Footer komponens */}</footer>
    </div>
  );
}
