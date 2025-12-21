import { css, Theme } from '@emotion/react';

/**
 * WelcomeHeader Styles - Dashboard welcome banner
 */

// Container
export const welcomeContainer = (theme: Theme) => css`
  padding: 24px;
  background: linear-gradient(135deg, #4F46E5, #7C3AED);
  border-radius: ${theme.radii['2xl']};
  box-shadow: 0 8px 20px rgba(79, 70, 229, 0.3);
`;

// Content wrapper
export const welcomeContent = (theme: Theme) => css`
  display: flex;
  align-items: center;
  gap: ${theme.spacing[4]};
`;

// Icon container
export const welcomeIconContainer = css`
  padding: 12px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
`;

// Text container
export const welcomeTextContainer = css`
  flex: 1;
`;

// Title
export const welcomeTitle = css`
  font-size: 24px;
  font-weight: 700;
  color: white;
  margin: 0;
`;

// Subtitle
export const welcomeSubtitle = css`
  font-size: 14px;
  color: rgba(255, 255, 255, 0.7);
  margin: 0;
`;
