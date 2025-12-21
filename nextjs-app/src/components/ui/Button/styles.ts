import { css, Theme } from '@emotion/react';

/**
 * Button Styles - Using CSS objects for better performance
 */

export type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
export type ButtonSize = 'sm' | 'md' | 'lg';

// Base button styles
export const buttonBase = (theme: Theme) => css`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: ${theme.spacing[2]};
  border-radius: ${theme.radii.lg};
  font-family: ${theme.typography.fontFamily};
  font-weight: ${theme.typography.weights.medium};
  transition: all ${theme.transitions.fast};
  cursor: pointer;
  white-space: nowrap;
  text-decoration: none;

  &:disabled {
    cursor: not-allowed;
    opacity: 0.6;
  }
`;

// Size variants
export const buttonSize = {
    sm: css`
    padding: 8px 16px;
    font-size: 13px;
    min-height: 32px;
  `,
    md: css`
    padding: 12px 24px;
    font-size: 14px;
    min-height: 44px;
  `,
    lg: css`
    padding: 16px 32px;
    font-size: 16px;
    min-height: 52px;
  `,
};

// Full width style
export const buttonFullWidth = css`
  width: 100%;
`;

// Loading state
export const buttonLoading = css`
  pointer-events: none;
  opacity: 0.7;
`;

// Button variants
export const getButtonVariant = (variant: ButtonVariant, theme: Theme) => {
    switch (variant) {
        case 'primary':
            return css`
        background-color: ${theme.colors.accent};
        color: ${theme.colors.textOnAccent};
        border: none;

        &:hover:not(:disabled) {
          background-color: ${theme.colors.primary};
        }

        &:active:not(:disabled) {
          transform: scale(0.98);
        }

        &:focus-visible {
          outline: 2px solid ${theme.colors.accent};
          outline-offset: 2px;
        }
      `;
        case 'secondary':
            return css`
        background-color: ${theme.colors.primary};
        color: ${theme.colors.textOnPrimary};
        border: none;

        &:hover:not(:disabled) {
          background-color: ${theme.colors.textPrimary};
        }

        &:active:not(:disabled) {
          transform: scale(0.98);
        }

        &:focus-visible {
          outline: 2px solid ${theme.colors.primary};
          outline-offset: 2px;
        }
      `;
        case 'outline':
            return css`
        background-color: transparent;
        color: ${theme.colors.primary};
        border: 1px solid ${theme.colors.border};

        &:hover:not(:disabled) {
          background-color: ${theme.colors.background};
          border-color: ${theme.colors.primary};
        }

        &:active:not(:disabled) {
          transform: scale(0.98);
        }

        &:focus-visible {
          outline: 2px solid ${theme.colors.accent};
          outline-offset: 2px;
        }
      `;
        case 'ghost':
            return css`
        background-color: transparent;
        color: ${theme.colors.textPrimary};
        border: none;

        &:hover:not(:disabled) {
          background-color: ${theme.colors.background};
        }

        &:active:not(:disabled) {
          transform: scale(0.98);
        }

        &:focus-visible {
          outline: 2px solid ${theme.colors.accent};
          outline-offset: 2px;
        }
      `;
        case 'danger':
            return css`
        background-color: ${theme.colors.error};
        color: white;
        border: none;

        &:hover:not(:disabled) {
          background-color: #dc2626;
        }

        &:active:not(:disabled) {
          transform: scale(0.98);
        }

        &:focus-visible {
          outline: 2px solid ${theme.colors.error};
          outline-offset: 2px;
        }
      `;
        default:
            return css``;
    }
};

// Spinner styles
export const spinnerStyles = css`
  width: 16px;
  height: 16px;
  border: 2px solid currentColor;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
`;
