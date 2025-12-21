import { css, Theme } from '@emotion/react';

/**
 * AppLayout Styles - Using CSS objects for better performance
 */

// Layout container
export const layoutContainer = (theme: Theme) => css`
  min-height: 100vh;
  display: flex;
  background-color: ${theme.colors.background};
`;

// Main wrapper
export const mainWrapper = (hasSidebar: boolean, theme: Theme) => css`
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 100vh;

  @media (min-width: ${theme.breakpoints.lg}) {
    margin-left: ${hasSidebar ? theme.layout.sidebarWidth : '0'};
  }
`;

// Content area
export const contentArea = (hasMobileNav: boolean, theme: Theme) => css`
  flex: 1;
  padding: ${theme.spacing[4]};
  overflow-x: hidden;

  @media (max-width: ${theme.breakpoints.lg}) {
    padding-bottom: ${hasMobileNav ? '80px' : undefined};
  }

  @media (min-width: ${theme.breakpoints.lg}) {
    padding: ${theme.spacing[6]};
  }
`;

// Auth container
export const authContainer = (theme: Theme) => css`
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: ${theme.colors.loginBackground};
`;

// Loading overlay
export const loadingOverlay = (theme: Theme) => css`
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: ${theme.colors.background};
  z-index: ${theme.zIndices.modal};
`;

// Spinner
export const spinner = (theme: Theme) => css`
  width: 40px;
  height: 40px;
  border: 3px solid ${theme.colors.divider};
  border-top-color: ${theme.colors.accent};
  border-radius: ${theme.radii.full};
  animation: spin 0.8s linear infinite;

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
`;
