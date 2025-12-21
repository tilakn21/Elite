import { css, Theme } from '@emotion/react';

/**
 * Input Styles - Using CSS objects for better performance
 */

export type InputSize = 'sm' | 'md' | 'lg';

// Container styles
export const inputContainer = (fullWidth: boolean) => css`
  display: flex;
  flex-direction: column;
  gap: 4px;
  width: ${fullWidth ? '100%' : 'auto'};
`;

// Label styles
export const inputLabel = (theme: Theme) => css`
  font-size: ${theme.typography.sizes.bodySmall};
  font-weight: ${theme.typography.weights.medium};
  color: ${theme.colors.textPrimary};
`;

// Input wrapper styles
export const inputWrapper = css`
  position: relative;
  display: flex;
  align-items: center;
`;

// Icon wrapper styles
export const inputIconWrapper = (position: 'left' | 'right') => css`
  position: absolute;
  ${position === 'left' ? 'left: 12px;' : 'right: 12px;'}
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;

  svg {
    width: 20px;
    height: 20px;
  }
`;

export const inputIconWrapperThemed = (theme: Theme) => css`
  color: ${theme.colors.textSecondary};
`;

// Size variants
export const inputSize = {
    sm: css`
    padding: 8px 12px;
    font-size: 13px;
    min-height: 36px;
  `,
    md: css`
    padding: 12px 16px;
    font-size: 14px;
    min-height: 44px;
  `,
    lg: css`
    padding: 16px 20px;
    font-size: 16px;
    min-height: 52px;
  `,
};

// Base input styles
export const inputBase = (theme: Theme) => css`
  width: 100%;
  border-radius: ${theme.radii.lg};
  background-color: ${theme.colors.surface};
  color: ${theme.colors.textPrimary};
  font-family: ${theme.typography.fontFamily};
  transition: border-color ${theme.transitions.fast},
    box-shadow ${theme.transitions.fast};

  &::placeholder {
    color: ${theme.colors.textSecondary};
  }

  &:disabled {
    background-color: ${theme.colors.background};
    color: ${theme.colors.textSecondary};
    cursor: not-allowed;
  }
`;

// Border styles based on error state
export const inputBorder = (hasError: boolean, theme: Theme) => css`
  border: 1px solid ${hasError ? theme.colors.error : theme.colors.border};

  &:hover:not(:disabled) {
    border-color: ${hasError ? theme.colors.error : theme.colors.textSecondary};
  }

  &:focus {
    outline: none;
    border-color: ${hasError ? theme.colors.error : theme.colors.accent};
    box-shadow: 0 0 0 3px ${hasError ? `${theme.colors.error}1A` : `${theme.colors.accent}1A`};
  }
`;

// Icon padding
export const inputLeftIconPadding = css`
  padding-left: 40px;
`;

export const inputRightIconPadding = css`
  padding-right: 40px;
`;

// Helper text styles
export const helperTextStyles = (isError: boolean, theme: Theme) => css`
  font-size: ${theme.typography.sizes.bodySmall};
  color: ${isError ? theme.colors.error : theme.colors.textSecondary};
`;
