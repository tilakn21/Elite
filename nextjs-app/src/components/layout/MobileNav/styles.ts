import { css, Theme } from '@emotion/react';

/**
 * MobileNav Styles - Using CSS objects for better performance
 */

// Nav container
export const navContainer = (theme: Theme) => css`
  display: flex;
  align-items: center;
  justify-content: space-around;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 64px;
  background-color: ${theme.colors.primary};
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  z-index: ${theme.zIndices.sticky};
  padding-bottom: env(safe-area-inset-bottom);

  @media (min-width: ${theme.breakpoints.lg}) {
    display: none;
  }
`;

// Nav item
export const mobileNavItem = (active: boolean, theme: Theme) => css`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  height: 100%;
  color: ${active ? theme.colors.accent : 'rgba(255, 255, 255, 0.7)'};
  text-decoration: none;
  font-size: ${theme.typography.sizes.caption};
  font-weight: ${theme.typography.weights.medium};
  transition: color ${theme.transitions.fast};
  gap: 4px;

  &:hover,
  &:active {
    color: ${theme.colors.accent};
  }

  svg {
    width: 24px;
    height: 24px;
  }
`;

// Nav label
export const mobileNavLabel = css`
  font-size: 11px;
`;
