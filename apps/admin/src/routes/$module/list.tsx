import { useParams } from 'react-router-dom';

/** Modul Lista oldal */
export default function ModuleListPage() {
  const { module } = useParams<{ module: string }>();
  return (
    <div>
      <h1 className="text-2xl font-bold">{module} – Lista</h1>
      {/* TODO: ListPage komponens (list-view skill) */}
    </div>
  );
}
export const Component = ModuleListPage;
