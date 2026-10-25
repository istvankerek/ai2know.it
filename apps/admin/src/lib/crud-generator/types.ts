/**
 * ModuleConfig + ListConfig interfeszek
 * Minden CRUD modul ebbol generlja a route-okat, formokat es listat.
 */

export interface ModuleConfig {
  slug: string;
  name: { hu: string; en: string };
  icon: string;
  source: string; // PostgreSQL schema (pl. "auth_schema")
  permissions: {
    list: string;
    create: string;
    update: string;
    delete: string;
    export: string;
    bulk: string;
  };
  fields: FieldDefinition[];
  list: ListConfig;
}

export interface FieldDefinition {
  slug: string;
  type: FieldType;
  label: { hu: string; en: string };
  required: boolean;
  searchable?: boolean;
  sortable?: boolean;
  filterable?: boolean;
  inList?: boolean;
  inForm?: boolean;
}

export type FieldType =
  | 'text' | 'number' | 'boolean' | 'select' | 'date'
  | 'relation' | 'file' | 'taxonomy' | 'email' | 'url'
  | 'rich-text' | 'color' | 'multiselect';

export type ExportFormat = 'csv' | 'xlsx' | 'pdf' | 'md' | 'json';

export interface ListConfig {
  columns: string[];
  search: {
    globalSearch: boolean;
    columnSearch: boolean;
    fuzzy: boolean;
    debounceMs: number;
    searchFields: string[];
  };
  filters: FilterConfig[];
  sorting: {
    multiSort: boolean;
    defaultSort: SortConfig[];
  };
  pagination: {
    options: (number | 'all')[];
    default: number;
    virtualScroll: boolean;
    allWarningThreshold: number;
  };
  selection: {
    mode: 'checkbox' | 'click' | 'none';
    selectPage: boolean;
    selectFiltered: boolean;
    selectAll: boolean;
  };
  bulk: {
    export: ExportFormat[];
    delete: boolean;
    edit: boolean;
    download: boolean;
    editableFields?: string[];
    customActions?: BulkAction[];
  };
  views: {
    savedViews: boolean;
    sharedViews: boolean;
    defaultView?: string;
  };
  advanced: {
    enabled: boolean;
    agGrid: AgGridConfig;
    inlineEdit: {
      enabled: boolean;
      simpleFields: FieldType[];
      complexFields: FieldType[];
    };
  };
}

export interface AgGridConfig {
  serverSideRowModel: boolean;
  rowGrouping: boolean;
  columnPinning: boolean;
  statusBar: boolean;
  clipboard: boolean;
  masterDetail: boolean;
  pivotMode: boolean;
  treeData: boolean;
  chartsIntegration: boolean;
  sparklines: boolean;
  aggregation: boolean;
}

export interface FilterConfig {
  field: string;
  type: 'text' | 'select' | 'multiselect' | 'daterange' | 'numberrange' | 'boolean' | 'taxonomy';
  options?: string | unknown[];
  label?: string;
}

export interface SortConfig {
  field: string;
  direction: 'asc' | 'desc';
}

export interface BulkAction {
  slug: string;
  label: string;
  icon?: string;
  permission: string;
  confirmation?: boolean;
  confirmText?: string;
  handler: 'api' | 'download' | 'custom';
  endpoint?: string;
}

export interface BulkRequest {
  action: string;
  selection:
    | { mode: 'individual'; ids: string[] }
    | { mode: 'filtered'; filters: Record<string, unknown> }
    | { mode: 'all' };
  changes?: Record<string, unknown>;
  format?: ExportFormat;
}
