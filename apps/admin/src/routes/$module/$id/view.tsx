import { useParams } from 'react-router-dom';

/** Modul elem reszletek */
export default function ModuleViewPage() {
  const { module, id } = useParams<{ module: string; id: string }>();
  return (
    <div>
      <h1 className="text-2xl font-bold">{module} #{id} – Reszletek</h1>
      {/* TODO: detail view implementacio */}
    </div>
  );
}
export const Component = ModuleViewPage;
