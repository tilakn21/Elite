import { css, Theme } from '@emotion/react';

/**
 * Card Styles - Using CSS objects for better performance
 * Styles are defined outside component to prevent recreation on each render
 */

export type CardVariant = 'elevated' | 'outlined' | 'filled';
export type CardPadding = 'none' | 'sm' | 'md' | 'lg';

// Base card styles
export const cardBase = (theme: Theme) => css`
  border-radius: ${theme.radii.xl};
  background-color: ${theme.colors.card};
  transition: box-shadow ${theme.transitions.fast},
    transform ${theme.transitions.fast};
`;

// Padding variants
export const cardPadding = {
    none: css`
    padding: 0;
  `,
    sm: css`
    padding: 12px;
  `,
    md: css`
    padding: 16px;
  `,
    lg: css`
    padding: 24px;
  `,
};

// Card variant styles
export const getCardVariant = (variant: CardVariant, theme: Theme) => {
    switch (variant) {
        case 'elevated':
            return css`
        box-shadow: ${theme.shadows.card};
        border: none;
      `;
        case 'outlined':
            return css`
        box-shadow: none;
        border: 1px solid ${theme.colors.divider};
      `;
        case 'filled':
            return css`
        box-shadow: none;
        border: none;
        background-color: ${theme.colors.background};
      `;
        default:
            return css``;
    }
};

// Hoverable styles
export const cardHoverable = (theme: Theme) => css`
  &:hover {
    box-shadow: ${theme.shadows.cardHover};
    transform: translateY(-2px);
  }
`;

// Clickable styles
export const cardClickable = css`
  cursor: pointer;
  user-select: none;

  &:active {
    transform: scale(0.99);
  }
`;

// Card sub-component styles
export const cardHeader = (theme: Theme) => css`
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: ${theme.spacing[4]};
  border-bottom: 1px solid ${theme.colors.divider};
  margin-bottom: ${theme.spacing[4]};
`;

export const cardTitle = (theme: Theme) => css`
  font-size: ${theme.typography.sizes.headlineMedium};
  font-weight: ${theme.typography.weights.semiBold};
  color: ${theme.colors.textPrimary};
  margin: 0;
`;

export const cardContent = css`
  /* Default content container */
`;

export const cardFooter = (theme: Theme) => css`
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: ${theme.spacing[3]};
  padding-top: ${theme.spacing[4]};
  border-top: 1px solid ${theme.colors.divider};
  margin-top: ${theme.spacing[4]};
`;
