import { css, Theme } from '@emotion/react';

/**
 * StatCard Styles - Dashboard stat card component
 */

// Card container
export const statCardContainer = (theme: Theme) => css`
  display: flex;
  flex-direction: column;
  gap: ${theme.spacing[2]};
  padding: ${theme.spacing[4]};
  background-color: ${theme.colors.card};
  border-radius: ${theme.radii.xl};
  border: 1px solid ${theme.colors.divider};
`;

// Stat label
export const statLabel = (theme: Theme) => css`
  font-size: ${theme.typography.sizes.bodySmall};
  color: ${theme.colors.textSecondary};
  text-transform: uppercase;
  letter-spacing: 0.5px;
`;

// Stat value
export const statValue = (theme: Theme) => css`
  font-size: 28px;
  font-weight: ${theme.typography.weights.bold};
  color: ${theme.colors.textPrimary};
`;

// Stat change
export const statChange = (positive: boolean, theme: Theme) => css`
  font-size: ${theme.typography.sizes.bodySmall};
  color: ${positive ? theme.colors.success : theme.colors.error};
  display: flex;
  align-items: center;
  gap: 4px;
`;
