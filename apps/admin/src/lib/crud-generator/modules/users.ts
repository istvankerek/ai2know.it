import type { ModuleConfig } from '../types';
import { DEFAULT_LIST_CONFIG } from '../defaults';

/** Users modul konfiguracio */
export const usersConfig: ModuleConfig = {
  slug: 'users',
  name: { hu: 'Felhasznalok', en: 'Users' },
  icon: 'Users',
  source: 'auth_schema',
  permissions: {
    list: 'users:list',
    create: 'users:create',
    update: 'users:update',
    delete: 'users:delete',
    export: 'users:export',
    bulk: 'users:bulk',
  },
  fields: [
    { slug: 'name', type: 'text', label: { hu: 'Nev', en: 'Name' }, required: true, searchable: true, sortable: true, filterable: false, inList: true, inForm: true },
    { slug: 'email', type: 'email', label: { hu: 'Email', en: 'Email' }, required: true, searchable: true, sortable: true, filterable: false, inList: true, inForm: true },
    { slug: 'role', type: 'select', label: { hu: 'Szerepkor', en: 'Role' }, required: true, searchable: false, sortable: true, filterable: true, inList: true, inForm: true },
    { slug: 'status', type: 'select', label: { hu: 'Statusz', en: 'Status' }, required: true, searchable: false, sortable: true, filterable: true, inList: true, inForm: true },
    { slug: 'created_at', type: 'date', label: { hu: 'Letrehozva', en: 'Created' }, required: false, searchable: false, sortable: true, filterable: true, inList: true, inForm: false },
  ],
  list: {
    ...DEFAULT_LIST_CONFIG,
    columns: ['name', 'email', 'role', 'status', 'created_at'],
    search: { ...DEFAULT_LIST_CONFIG.search, searchFields: ['name', 'email'] },
    filters: [
      { field: 'role', type: 'multiselect', options: ['super_admin', 'admin', 'editor', 'viewer'] },
      { field: 'status', type: 'multiselect', options: ['active', 'inactive', 'blocked'] },
      { field: 'created_at', type: 'daterange' },
    ],
  },
};
