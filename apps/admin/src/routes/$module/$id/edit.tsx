import { useParams } from 'react-router-dom';

/** Modul elem szerkesztes */
export default function ModuleEditPage() {
  const { module, id } = useParams<{ module: string; id: string }>();
  return (
    <div>
      <h1 className="text-2xl font-bold">{module} #{id} – Szerkesztes</h1>
      {/* TODO: form-builder skill */}
    </div>
  );
}
export const Component = ModuleEditPage;
