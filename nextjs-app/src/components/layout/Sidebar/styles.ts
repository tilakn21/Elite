import { css, Theme } from '@emotion/react';

/**
 * Sidebar Styles - Using CSS objects for better performance
 */

// Sidebar container
export const sidebarContainer = (collapsed: boolean, theme: Theme) => css`
  display: none;
  flex-direction: column;
  width: ${collapsed ? theme.layout.sidebarCollapsedWidth : theme.layout.sidebarWidth};
  min-height: 100vh;
  background-color: ${theme.colors.primary};
  transition: width ${theme.transitions.normal};
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  z-index: ${theme.zIndices.sticky};

  @media (min-width: ${theme.breakpoints.lg}) {
    display: flex;
  }
`;

// Logo
export const logo = (theme: Theme) => css`
  padding: ${theme.spacing[6]};
  display: flex;
  align-items: center;
  justify-content: center;
`;

export const logoText = (theme: Theme) => css`
  color: ${theme.colors.textOnPrimary};
  font-size: 24px;
  font-weight: ${theme.typography.weights.bold};
`;

// Divider
export const divider = css`
  border: none;
  border-top: 1px solid rgba(255, 255, 255, 0.24);
  margin: 0;
`;

// Nav list
export const navList = (theme: Theme) => css`
  display: flex;
  flex-direction: column;
  flex: 1;
  padding: ${theme.spacing[2]} 0;
`;

// Nav item
export const navItem = (active: boolean, theme: Theme) => css`
  display: flex;
  align-items: center;
  padding: ${theme.spacing[4]};
  color: ${theme.colors.textOnPrimary};
  text-decoration: none;
  font-size: ${theme.typography.sizes.bodyMedium};
  font-weight: ${theme.typography.weights.medium};
  transition: background-color ${theme.transitions.fast};
  border-left: 4px solid ${active ? theme.colors.accent : 'transparent'};
  background-color: ${active ? 'rgba(255, 255, 255, 0.1)' : 'transparent'};

  &:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }

  svg {
    margin-right: ${theme.spacing[4]};
    flex-shrink: 0;
  }
`;

// Nav label
export const navLabel = css`
  white-space: pre-line;
`;

// User section
export const userSectionStyles = (theme: Theme) => css`
  padding: ${theme.spacing[4]};
  margin-top: auto;
`;

// User info
export const userInfo = (theme: Theme) => css`
  display: flex;
  align-items: center;
  gap: ${theme.spacing[2]};
`;

// User avatar
export const userAvatar = (theme: Theme) => css`
  width: 32px;
  height: 32px;
  border-radius: ${theme.radii.full};
  background-color: ${theme.colors.surface};
  color: ${theme.colors.primary};
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: ${theme.typography.weights.bold};
  font-size: 14px;
`;

// User details
export const userDetails = css`
  flex: 1;
  min-width: 0;
`;

// User name
export const userNameStyles = (theme: Theme) => css`
  font-size: ${theme.typography.sizes.bodyMedium};
  font-weight: ${theme.typography.weights.medium};
  color: ${theme.colors.textOnPrimary};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;

// User role
export const userRoleStyles = (theme: Theme) => css`
  font-size: ${theme.typography.sizes.bodySmall};
  color: rgba(255, 255, 255, 0.7);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-transform: capitalize;
`;

// Logout button
export const logoutButton = (theme: Theme) => css`
  display: flex;
  align-items: center;
  width: 100%;
  padding: ${theme.spacing[4]};
  color: ${theme.colors.textOnPrimary};
  font-size: ${theme.typography.sizes.bodyMedium};
  font-weight: ${theme.typography.weights.medium};
  transition: background-color ${theme.transitions.fast};
  border-left: 4px solid transparent;
  background: transparent;
  border: none;
  cursor: pointer;

  &:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }

  svg {
    margin-right: ${theme.spacing[4]};
  }
`;
