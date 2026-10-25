import type { ModuleConfig } from '../types';
import { DEFAULT_LIST_CONFIG } from '../defaults';

/** Products modul konfiguracio */
export const productsConfig: ModuleConfig = {
  slug: 'products',
  name: { hu: 'Termekek', en: 'Products' },
  icon: 'Package',
  source: 'product_schema',
  permissions: {
    list: 'products:list',
    create: 'products:create',
    update: 'products:update',
    delete: 'products:delete',
    export: 'products:export',
    bulk: 'products:bulk',
  },
  fields: [
    { slug: 'name', type: 'text', label: { hu: 'Nev', en: 'Name' }, required: true, searchable: true, sortable: true, filterable: false, inList: true, inForm: true },
    { slug: 'price', type: 'number', label: { hu: 'Ar', en: 'Price' }, required: true, searchable: false, sortable: true, filterable: true, inList: true, inForm: true },
    { slug: 'category', type: 'taxonomy', label: { hu: 'Kategoria', en: 'Category' }, required: true, searchable: false, sortable: true, filterable: true, inList: true, inForm: true },
    { slug: 'status', type: 'select', label: { hu: 'Statusz', en: 'Status' }, required: true, searchable: false, sortable: true, filterable: true, inList: true, inForm: true },
    { slug: 'created_at', type: 'date', label: { hu: 'Letrehozva', en: 'Created' }, required: false, searchable: false, sortable: true, filterable: true, inList: true, inForm: false },
  ],
  list: {
    ...DEFAULT_LIST_CONFIG,
    columns: ['name', 'price', 'category', 'status', 'created_at'],
    search: { ...DEFAULT_LIST_CONFIG.search, searchFields: ['name'] },
    filters: [
      { field: 'category', type: 'taxonomy', options: 'taxonomy:product_categories' },
      { field: 'status', type: 'multiselect', options: ['active', 'draft', 'archived'] },
      { field: 'price', type: 'numberrange' },
      { field: 'created_at', type: 'daterange' },
    ],
  },
};
