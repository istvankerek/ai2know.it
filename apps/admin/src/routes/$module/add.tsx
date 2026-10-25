import { useParams } from 'react-router-dom';

/** Modul uj elem hozzaadas */
export default function ModuleAddPage() {
  const { module } = useParams<{ module: string }>();
  return (
    <div>
      <h1 className="text-2xl font-bold">{module} – Uj elem</h1>
      {/* TODO: form-builder skill */}
    </div>
  );
}
export const Component = ModuleAddPage;
