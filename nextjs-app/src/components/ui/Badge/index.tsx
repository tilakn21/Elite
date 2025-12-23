/**
 * Badge Component
 * Status indicator with color variants
 */

import styled from '@emotion/styled';

type BadgeVariant =
    | 'default'
    | 'success'
    | 'warning'
    | 'error'
    | 'info'
    | 'pending'
    | 'in_progress'
    | 'completed';

interface BadgeProps {
    children: React.ReactNode;
    variant?: BadgeVariant;
    size?: 'sm' | 'md';
    className?: string;
}

const variantStyles: Record<BadgeVariant, { bg: string; color: string; border: string }> = {
    default: { bg: '#f3f4f6', color: '#374151', border: '#e5e7eb' },
    success: { bg: '#dcfce7', color: '#166534', border: '#bbf7d0' },
    warning: { bg: '#fef3c7', color: '#92400e', border: '#fde68a' },
    error: { bg: '#fee2e2', color: '#dc2626', border: '#fecaca' },
    info: { bg: '#dbeafe', color: '#1d4ed8', border: '#bfdbfe' },
    pending: { bg: '#fef3c7', color: '#92400e', border: '#fde68a' },
    in_progress: { bg: '#dbeafe', color: '#1d4ed8', border: '#bfdbfe' },
    completed: { bg: '#dcfce7', color: '#166534', border: '#bbf7d0' },
};

const StyledBadge = styled.span<{ variant: BadgeVariant; size: 'sm' | 'md' }>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: ${({ size }) => (size === 'sm' ? '2px 8px' : '4px 12px')};
  font-size: ${({ size }) => (size === 'sm' ? '11px' : '12px')};
  font-weight: 600;
  border-radius: 9999px;
  text-transform: capitalize;
  white-space: nowrap;
  background-color: ${({ variant }) => variantStyles[variant].bg};
  color: ${({ variant }) => variantStyles[variant].color};
  border: 1px solid ${({ variant }) => variantStyles[variant].border};
`;

export function Badge({
    children,
    variant = 'default',
    size = 'md',
    className
}: BadgeProps) {
    return (
        <StyledBadge variant={variant} size={size} className={className}>
            {children}
        </StyledBadge>
    );
}

/**
 * Status Badge - auto-selects variant based on status text
 * Supports unified job statuses and payment statuses
 */
export function StatusBadge({ status, size = 'md' }: { status: string; size?: 'sm' | 'md' }) {
    const normalizedStatus = status.toLowerCase().replace(/[\s]/g, '_');

    let variant: BadgeVariant = 'default';

    // Success statuses (completed/approved states)
    if ([
        'completed', 'done', 'approved', 'paid', 'payment_done',
        'design_approved', 'production_completed', 'printing_completed', 'out_for_delivery'
    ].includes(normalizedStatus)) {
        variant = 'success';
    }
    // In-progress statuses
    else if ([
        'in_progress', 'processing', 'active', 'started',
        'salesperson_assigned', 'site_visited', 'design_started',
        'production_started', 'printing_started', 'partially_paid'
    ].includes(normalizedStatus)) {
        variant = 'info';
    }
    // Pending/waiting statuses
    else if ([
        'pending', 'waiting', 'new', 'draft', 'received',
        'design_in_review', 'payment_pending'
    ].includes(normalizedStatus)) {
        variant = 'warning';
    }
    // Error/failed statuses
    else if ([
        'failed', 'rejected', 'cancelled', 'error', 'overdue'
    ].includes(normalizedStatus)) {
        variant = 'error';
    }

    // Format display text (convert underscores to spaces, capitalize)
    const displayText = status
        .replace(/_/g, ' ')
        .replace(/\b\w/g, c => c.toUpperCase());

    return (
        <Badge variant={variant} size={size}>
            {displayText}
        </Badge>
    );
}

export default Badge;
