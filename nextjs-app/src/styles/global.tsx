import { css, Global } from '@emotion/react';
import { theme } from './theme';

/**
 * Global Styles - CSS Reset and Base Typography
 * Matches Flutter's ThemeData configuration
 */
export const globalStyles = (
    <Global
        styles={css`
      /* CSS Reset */
      *,
      *::before,
      *::after {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
      }

      /* Document */
      html {
        font-size: 16px;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-rendering: optimizeLegibility;
      }

      body {
        font-family: ${theme.typography.fontFamily};
        font-size: ${theme.typography.sizes.bodyMedium};
        font-weight: ${theme.typography.weights.regular};
        line-height: ${theme.typography.lineHeights.normal};
        color: ${theme.colors.textPrimary};
        background-color: ${theme.colors.background};
        min-height: 100vh;
      }

      /* Typography */
      h1,
      h2,
      h3,
      h4,
      h5,
      h6 {
        font-weight: ${theme.typography.weights.semiBold};
        line-height: ${theme.typography.lineHeights.tight};
        color: ${theme.colors.textPrimary};
      }

      h1 {
        font-size: ${theme.typography.sizes.displayLarge};
        font-weight: ${theme.typography.weights.bold};
      }

      h2 {
        font-size: ${theme.typography.sizes.displayMedium};
      }

      h3 {
        font-size: ${theme.typography.sizes.displaySmall};
      }

      h4 {
        font-size: ${theme.typography.sizes.headlineMedium};
      }

      h5 {
        font-size: ${theme.typography.sizes.headlineSmall};
      }

      p {
        color: ${theme.colors.textSecondary};
      }

      /* Links */
      a {
        color: ${theme.colors.accent};
        text-decoration: none;
        transition: color ${theme.transitions.fast};

        &:hover {
          color: ${theme.colors.primary};
        }

        &:focus-visible {
          outline: 2px solid ${theme.colors.accent};
          outline-offset: 2px;
          border-radius: ${theme.radii.sm};
        }
      }

      /* Buttons - Reset */
      button {
        font-family: inherit;
        font-size: inherit;
        cursor: pointer;
        border: none;
        background: none;

        &:disabled {
          cursor: not-allowed;
          opacity: 0.6;
        }
      }

      /* Inputs - Reset */
      input,
      textarea,
      select {
        font-family: inherit;
        font-size: inherit;
        border: 1px solid ${theme.colors.border};
        border-radius: ${theme.radii.lg};
        padding: ${theme.spacing[3]} ${theme.spacing[4]};
        background-color: ${theme.colors.surface};
        transition: border-color ${theme.transitions.fast},
          box-shadow ${theme.transitions.fast};

        &:focus {
          outline: none;
          border-color: ${theme.colors.accent};
          box-shadow: 0 0 0 3px rgba(78, 205, 196, 0.1);
        }

        &::placeholder {
          color: ${theme.colors.textSecondary};
        }

        &:disabled {
          background-color: ${theme.colors.background};
          cursor: not-allowed;
        }
      }

      /* Lists */
      ul,
      ol {
        list-style: none;
      }

      /* Images */
      img {
        max-width: 100%;
        height: auto;
        display: block;
      }

      /* Focus visible for accessibility */
      :focus-visible {
        outline: 2px solid ${theme.colors.accent};
        outline-offset: 2px;
      }

      /* Remove focus outline for mouse users */
      :focus:not(:focus-visible) {
        outline: none;
      }

      /* Scrollbar styling */
      ::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }

      ::-webkit-scrollbar-track {
        background: ${theme.colors.background};
        border-radius: ${theme.radii.full};
      }

      ::-webkit-scrollbar-thumb {
        background: ${theme.colors.divider};
        border-radius: ${theme.radii.full};

        &:hover {
          background: ${theme.colors.textSecondary};
        }
      }

      /* Selection */
      ::selection {
        background-color: ${theme.colors.accent};
        color: ${theme.colors.textOnAccent};
      }

      /* Animations - Reduce motion for accessibility */
      @media (prefers-reduced-motion: reduce) {
        *,
        *::before,
        *::after {
          animation-duration: 0.01ms !important;
          animation-iteration-count: 1 !important;
          transition-duration: 0.01ms !important;
        }
      }
    `}
    />
);

export default globalStyles;
