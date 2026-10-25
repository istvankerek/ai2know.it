import { createBrowserRouter } from 'react-router-dom';
import AdminRoot from './root';

export const router = createBrowserRouter([
  {
    path: '/',
    Component: AdminRoot,
    children: [
      // Dashboard
      { index: true, lazy: () => import('./routes/_index') },

      // Dinamikus CRUD modulok
      { path: ':module/dashboard', lazy: () => import('./routes/$module/dashboard') },
      { path: ':module/list', lazy: () => import('./routes/$module/list') },
      { path: ':module/add', lazy: () => import('./routes/$module/add') },
      { path: ':module/:id/edit', lazy: () => import('./routes/$module/$id/edit') },
      { path: ':module/:id/view', lazy: () => import('./routes/$module/$id/view') },

      // Settings
      { path: 'settings/roles', lazy: () => import('./routes/settings/roles') },
      { path: 'settings/notifications', lazy: () => import('./routes/settings/notifications') },
      { path: 'settings/maintenance', lazy: () => import('./routes/settings/maintenance') },
      { path: 'settings/api-keys', lazy: () => import('./routes/settings/api-keys') },
      { path: 'settings/backups', lazy: () => import('./routes/settings/backups') },
      { path: 'settings/alerts', lazy: () => import('./routes/settings/alerts') },

      // Analytics
      { path: 'analytics/system', lazy: () => import('./routes/analytics/system') },
      { path: 'analytics/workers', lazy: () => import('./routes/analytics/workers') },
      { path: 'analytics/api', lazy: () => import('./routes/analytics/api') },
      { path: 'analytics/ai-cost', lazy: () => import('./routes/analytics/ai-cost') },

      // Egyeb
      { path: 'files', lazy: () => import('./routes/files') },
      { path: 'support', lazy: () => import('./routes/support') },
      { path: 'scraper', lazy: () => import('./routes/scraper') },
      { path: 'spider', lazy: () => import('./routes/spider') },
    ],
  },
]);
