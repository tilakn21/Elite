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
 */
export function StatusBadge({ status, size = 'md' }: { status: string; size?: 'sm' | 'md' }) {
    const normalizedStatus = status.toLowerCase().replace(/[_\s]/g, '_');

    let variant: BadgeVariant = 'default';

    if (['completed', 'done', 'approved', 'paid'].includes(normalizedStatus)) {
        variant = 'success';
    } else if (['in_progress', 'processing', 'active'].includes(normalizedStatus)) {
        variant = 'info';
    } else if (['pending', 'waiting', 'new', 'draft'].includes(normalizedStatus)) {
        variant = 'warning';
    } else if (['failed', 'rejected', 'cancelled', 'error'].includes(normalizedStatus)) {
        variant = 'error';
    }

    // Format display text
    const displayText = status.replace(/_/g, ' ');

    return (
        <Badge variant={variant} size={size}>
            {displayText}
        </Badge>
    );
}

export default Badge;
