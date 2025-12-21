/**
 * Table Component
 * Responsive data table for dashboards
 */

import styled from '@emotion/styled';
import { StatusBadge } from '../Badge';

interface Column<T> {
  key: keyof T | string;
  header: string;
  width?: string;
  render?: (row: T) => React.ReactNode;
}

interface TableProps<T> {
  columns: Column<T>[];
  data: T[];
  loading?: boolean;
  emptyMessage?: string;
  onRowClick?: (row: T) => void;
}

const TableContainer = styled.div`
  width: 100%;
  overflow-x: auto;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
`;

const StyledTable = styled.table`
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
`;

const TableHead = styled.thead`
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
`;

const TableHeader = styled.th<{ width?: string }>`
  padding: 14px 16px;
  text-align: left;
  font-weight: 600;
  color: #374151;
  font-size: 13px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
  width: ${({ width }) => width ?? 'auto'};
`;

const TableBody = styled.tbody``;

const TableRow = styled.tr<{ clickable?: boolean }>`
  border-bottom: 1px solid #f3f4f6;
  transition: background-color 0.15s;
  cursor: ${({ clickable }) => (clickable ? 'pointer' : 'default')};

  &:hover {
    background-color: ${({ clickable }) => (clickable ? '#f9fafb' : 'transparent')};
  }

  &:last-child {
    border-bottom: none;
  }
`;

const TableCell = styled.td`
  padding: 14px 16px;
  color: #1f2937;
  vertical-align: middle;
`;

const LoadingRow = styled.tr`
  td {
    padding: 40px 16px;
    text-align: center;
    color: #6b7280;
  }
`;

const EmptyRow = styled.tr`
  td {
    padding: 40px 16px;
    text-align: center;
    color: #9ca3af;
    font-size: 14px;
  }
`;

const Spinner = styled.div`
  display: inline-block;
  width: 24px;
  height: 24px;
  border: 3px solid #e5e7eb;
  border-top-color: #6366f1;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
`;

// Mobile card view for small screens
const MobileCards = styled.div`
  display: none;

  @media (max-width: 768px) {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 12px;
  }
`;

const MobileCard = styled.div<{ clickable?: boolean }>`
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px;
  cursor: ${({ clickable }) => (clickable ? 'pointer' : 'default')};

  &:hover {
    border-color: ${({ clickable }) => (clickable ? '#d1d5db' : '#e5e7eb')};
    box-shadow: ${({ clickable }) => (clickable ? '0 2px 8px rgba(0,0,0,0.05)' : 'none')};
  }
`;

const MobileCardRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 0;

  &:first-of-type {
    padding-top: 0;
  }

  &:last-of-type {
    padding-bottom: 0;
  }
`;

const MobileCardLabel = styled.span`
  font-size: 12px;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.5px;
`;

const MobileCardValue = styled.span`
  font-size: 14px;
  color: #1f2937;
  font-weight: 500;
`;

const DesktopTable = styled.div`
  @media (max-width: 768px) {
    display: none;
  }
`;

export function Table<T extends object>({
  columns,
  data,
  loading = false,
  emptyMessage = 'No data available',
  onRowClick,
}: TableProps<T>) {
  const getValue = (row: T, key: string): unknown => {
    return key.split('.').reduce((obj: unknown, k) => {
      if (obj && typeof obj === 'object' && k in obj) {
        return (obj as Record<string, unknown>)[k];
      }
      return undefined;
    }, row);
  };

  const renderCell = (row: T, column: Column<T>) => {
    if (column.render) {
      return column.render(row);
    }

    const value = getValue(row, column.key as string);

    // Auto-render status badges
    if (column.key === 'status' && typeof value === 'string') {
      return <StatusBadge status={value} />;
    }

    return String(value ?? '—');
  };

  return (
    <TableContainer>
      {/* Desktop table */}
      <DesktopTable>
        <StyledTable>
          <TableHead>
            <tr>
              {columns.map((column) => (
                <TableHeader key={String(column.key)} width={column.width}>
                  {column.header}
                </TableHeader>
              ))}
            </tr>
          </TableHead>
          <TableBody>
            {loading ? (
              <LoadingRow>
                <td colSpan={columns.length}>
                  <Spinner />
                </td>
              </LoadingRow>
            ) : data.length === 0 ? (
              <EmptyRow>
                <td colSpan={columns.length}>{emptyMessage}</td>
              </EmptyRow>
            ) : (
              data.map((row, index) => (
                <TableRow
                  key={index}
                  clickable={!!onRowClick}
                  onClick={() => onRowClick?.(row)}
                >
                  {columns.map((column) => (
                    <TableCell key={String(column.key)}>
                      {renderCell(row, column)}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </StyledTable>
      </DesktopTable>

      {/* Mobile card view */}
      <MobileCards>
        {loading ? (
          <MobileCard>
            <div style={{ textAlign: 'center', padding: '20px 0' }}>
              <Spinner />
            </div>
          </MobileCard>
        ) : data.length === 0 ? (
          <MobileCard>
            <div style={{ textAlign: 'center', color: '#9ca3af' }}>{emptyMessage}</div>
          </MobileCard>
        ) : (
          data.map((row, index) => (
            <MobileCard
              key={index}
              clickable={!!onRowClick}
              onClick={() => onRowClick?.(row)}
            >
              {columns.map((column) => (
                <MobileCardRow key={String(column.key)}>
                  <MobileCardLabel>{column.header}</MobileCardLabel>
                  <MobileCardValue>{renderCell(row, column)}</MobileCardValue>
                </MobileCardRow>
              ))}
            </MobileCard>
          ))
        )}
      </MobileCards>
    </TableContainer>
  );
}

export default Table;
