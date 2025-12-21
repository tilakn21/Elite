/**
 * Admin Job Details Page Styles
 */
import { css, Theme } from '@emotion/react';

export const container = (theme: Theme) => css`
    display: flex;
    flex-direction: column;
    gap: ${theme.spacing[6]};
    max-width: 1200px;
    margin: 0 auto;
    width: 100%;
`;

export const header = css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #fff;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
`;

export const headerLeft = css`
    display: flex;
    align-items: center;
    gap: 16px;
`;

export const backButton = (theme: Theme) => css`
    width: 40px;
    height: 40px;
    border-radius: 8px;
    border: 1px solid ${theme.colors.border};
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    background: #fff;
    color: ${theme.colors.textPrimary};
    &:hover {
        background: ${theme.colors.background};
    }
`;

export const titleSection = css`
    display: flex;
    flex-direction: column;
`;

export const jobTitle = css`
    font-size: 20px;
    font-weight: 700;
    color: #111827;
    margin: 0;
`;

export const subtitle = css`
    font-size: 14px;
    color: #6b7280;
    margin-top: 4px;
`;

export const headerActions = css`
    display: flex;
    gap: 12px;
`;

export const contentLayout = css`
    display: grid;
    grid-template-columns: 3fr 1fr;
    gap: 24px;
    
    @media (max-width: 1024px) {
        grid-template-columns: 1fr;
    }
`;

export const mainContent = css`
    display: flex;
    flex-direction: column;
    gap: 24px;
`;

export const sidebar = css`
    display: flex;
    flex-direction: column;
    gap: 24px;
`;

export const overviewCard = css`
    background: #fff;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
`;
