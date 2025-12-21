import { css, Theme } from '@emotion/react';

/**
 * Header Styles - Using CSS objects for better performance
 */

// Header container
export const headerContainer = (theme: Theme) => css`
  display: flex;
  align-items: center;
  height: ${theme.layout.headerHeight};
  padding: 0 ${theme.spacing[4]};
  background-color: ${theme.colors.surface};
  border-bottom: 1px solid ${theme.colors.divider};
  box-shadow: ${theme.shadows.sm};
  position: sticky;
  top: 0;
  z-index: ${theme.zIndices.sticky};
`;

// Menu button
export const menuButton = (theme: Theme) => css`
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: ${theme.radii.lg};
  color: ${theme.colors.textPrimary};
  background: transparent;
  border: none;
  cursor: pointer;
  transition: background-color ${theme.transitions.fast};

  &:hover {
    background-color: ${theme.colors.background};
  }

  @media (min-width: ${theme.breakpoints.lg}) {
    display: none;
  }
`;

// Search container
export const searchContainer = (theme: Theme) => css`
  flex: 1;
  max-width: 400px;
  margin: 0 ${theme.spacing[4]};

  @media (max-width: ${theme.breakpoints.sm}) {
    display: none;
  }
`;

// Search wrapper
export const searchWrapper = css`
  position: relative;
`;

// Search input
export const searchInput = (theme: Theme) => css`
  width: 100%;
  padding: ${theme.spacing[2]} ${theme.spacing[4]};
  padding-left: 40px;
  border-radius: ${theme.radii.full};
  border: none;
  background-color: ${theme.colors.background};
  font-size: ${theme.typography.sizes.bodyMedium};
  color: ${theme.colors.textPrimary};

  &::placeholder {
    color: ${theme.colors.textSecondary};
  }

  &:focus {
    outline: none;
    box-shadow: 0 0 0 2px ${theme.colors.accent}33;
  }
`;

// Search icon
export const searchIcon = (theme: Theme) => css`
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: ${theme.colors.textSecondary};
  display: flex;
  align-items: center;
`;

// Actions container
export const actions = (theme: Theme) => css`
  display: flex;
  align-items: center;
  gap: ${theme.spacing[4]};
  margin-left: auto;
`;

// Icon button
export const iconButton = (theme: Theme) => css`
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: ${theme.radii.full};
  color: ${theme.colors.textPrimary};
  background: transparent;
  border: none;
  cursor: pointer;
  transition: background-color ${theme.transitions.fast};

  &:hover {
    background-color: ${theme.colors.background};
  }
`;

// Hide on mobile
export const hideMobile = (theme: Theme) => css`
  @media (max-width: ${theme.breakpoints.sm}) {
    display: none;
  }
`;

// User section
export const userSection = (theme: Theme) => css`
  display: flex;
  align-items: center;
  gap: ${theme.spacing[2]};
`;

// User name
export const userName = (theme: Theme) => css`
  font-weight: ${theme.typography.weights.medium};
  font-size: ${theme.typography.sizes.bodyMedium};
  color: ${theme.colors.textPrimary};

  @media (max-width: ${theme.breakpoints.md}) {
    display: none;
  }
`;

// Avatar
export const avatar = (size: number = 32, theme: Theme) => css`
  width: ${size}px;
  height: ${size}px;
  border-radius: ${theme.radii.full};
  background-color: ${theme.colors.primary};
  color: ${theme.colors.textOnPrimary};
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: ${theme.typography.weights.bold};
  font-size: ${size * 0.4}px;
`;
