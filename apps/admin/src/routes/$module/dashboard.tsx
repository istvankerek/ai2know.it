import { useParams } from 'react-router-dom';

/** Modul Dashboard oldal */
export default function ModuleDashboardPage() {
  const { module } = useParams<{ module: string }>();
  return (
    <div>
      <h1 className="text-2xl font-bold">{module} – Dashboard</h1>
      {/* TODO: dashboard-widgets skill */}
    </div>
  );
}
export const Component = ModuleDashboardPage;
