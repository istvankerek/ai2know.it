import { useState } from 'react';

/** Simple/Advanced ful valto wrapper */
interface ListPageProps {
  moduleSlug: string;
  advancedEnabled?: boolean;
}

export default function ListPage({ moduleSlug, advancedEnabled = true }: ListPageProps) {
  const [viewMode, setViewMode] = useState<'simple' | 'advanced'>('simple');

  return (
    <div>
      {advancedEnabled && (
        <div className="mb-4 flex gap-2">
          <button onClick={() => setViewMode('simple')} className={viewMode === 'simple' ? 'font-bold' : ''}>Simple</button>
          <button onClick={() => setViewMode('advanced')} className={viewMode === 'advanced' ? 'font-bold' : ''}>Advanced</button>
        </div>
      )}
      {/* TODO: viewMode === 'simple' ? <SimpleList /> : <AdvancedList /> */}
    </div>
  );
}
