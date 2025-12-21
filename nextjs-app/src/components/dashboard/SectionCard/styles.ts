import { css, Theme } from '@emotion/react';

/**
 * SectionCard Styles - Dashboard section container
 */

// Container
export const sectionCardContainer = (theme: Theme) => css`
  background-color: ${theme.colors.card};
  border-radius: ${theme.radii['2xl']};
  border: 1px solid ${theme.colors.divider};
  padding: ${theme.spacing[6]};
  min-height: 300px;
`;

// Header
export const sectionHeader = (theme: Theme) => css`
  display: flex;
  align-items: center;
  gap: ${theme.spacing[3]};
  margin-bottom: ${theme.spacing[5]};
`;

// Icon container
export const sectionIconContainer = (color: string) => css`
  padding: 8px;
  background-color: ${color}1A;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;

  svg {
    width: 20px;
    height: 20px;
    color: ${color};
  }
`;

// Title
export const sectionTitle = (theme: Theme) => css`
  font-size: 20px;
  font-weight: ${theme.typography.weights.bold};
  color: ${theme.colors.textPrimary};
  margin: 0;
`;

// Placeholder content
export const placeholderContent = (theme: Theme) => css`
  display: flex;
  align-items: center;
  justify-content: center;
  height: 200px;
  background-color: ${theme.colors.background};
  border-radius: ${theme.radii.lg};
  color: ${theme.colors.textSecondary};
  font-size: ${theme.typography.sizes.bodyMedium};
`;

// Empty state
export const emptyState = (theme: Theme) => css`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: ${theme.spacing[8]};
  gap: ${theme.spacing[4]};

  svg {
    width: 48px;
    height: 48px;
    color: ${theme.colors.textMuted};
  }
`;

export const emptyStateTitle = (theme: Theme) => css`
  font-size: ${theme.typography.sizes.headlineMedium};
  font-weight: ${theme.typography.weights.semiBold};
  color: ${theme.colors.textPrimary};
`;

export const emptyStateText = (theme: Theme) => css`
  font-size: ${theme.typography.sizes.bodyMedium};
  color: ${theme.colors.textSecondary};
  text-align: center;
`;
