import type { ListConfig } from './types';

/** Alapertelmezett lista konfiguracio minden modulhoz */
export const DEFAULT_LIST_CONFIG: ListConfig = {
  columns: [],
  search: {
    globalSearch: true,
    columnSearch: false,
    fuzzy: true,
    debounceMs: 300,
    searchFields: [],
  },
  sorting: {
    multiSort: true,
    defaultSort: [{ field: 'created_at', direction: 'desc' }],
  },
  pagination: {
    options: [50, 100, 500, 1000, 'all'],
    default: 50,
    virtualScroll: true,
    allWarningThreshold: 5000,
  },
  selection: {
    mode: 'checkbox',
    selectPage: true,
    selectFiltered: true,
    selectAll: true,
  },
  bulk: {
    export: ['csv', 'xlsx', 'pdf', 'md', 'json'],
    delete: true,
    edit: true,
    download: false,
    customActions: [],
  },
  views: {
    savedViews: true,
    sharedViews: true,
  },
  advanced: {
    enabled: true,
    agGrid: {
      serverSideRowModel: true,
      rowGrouping: true,
      columnPinning: true,
      statusBar: true,
      clipboard: true,
      masterDetail: false,
      pivotMode: false,
      treeData: false,
      chartsIntegration: false,
      sparklines: false,
      aggregation: false,
    },
    inlineEdit: {
      enabled: true,
      simpleFields: ['text', 'number', 'boolean', 'select'],
      complexFields: ['relation', 'date', 'file', 'taxonomy'],
    },
  },
};
