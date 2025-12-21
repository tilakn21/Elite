/**
 * Admin Dashboard Styles
 */
import { css, Theme } from '@emotion/react';

export const container = (theme: Theme) => css`
    display: flex;
    flex-direction: column;
    gap: ${theme.spacing[6]};
`;

export const statsGrid = (theme: Theme) => css`
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: ${theme.spacing[6]};
    margin-bottom: ${theme.spacing[8]};
`;

export const sectionTitle = css`
    font-size: 18px;
    font-weight: 600;
    color: #374151;
    margin-bottom: 16px;
`;

// Portal Access Styles
export const portalGrid = (theme: Theme) => css`
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: ${theme.spacing[4]};
    margin-bottom: ${theme.spacing[8]};
`;

export const portalCard = css`
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: white;
    padding: 24px;
    border-radius: 12px;
    border: 1px solid #e5e7eb;
    cursor: pointer;
    transition: all 0.2s ease;
    text-align: center;
    gap: 12px;

    &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        border-color: #d1d5db;
    }

    h3 {
        font-size: 15px;
        font-weight: 600;
        color: #111827;
        margin: 0;
    }

    p {
        font-size: 13px;
        color: #6b7280;
        margin: 0;
    }
`;

export const iconWrapper = (color: string) => css`
    width: 48px;
    height: 48px;
    border-radius: 12px;
    background-color: ${color}15; // 15% opacity
    color: ${color};
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 4px;

    svg {
        width: 24px;
        height: 24px;
    }
`;

// Content Layout
export const contentGrid = (theme: Theme) => css`
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: ${theme.spacing[6]};

    @media (max-width: 1024px) {
        grid-template-columns: 1fr;
    }
`;

export const tableWrapper = css`
    overflow-x: auto;
    
    table {
        width: 100%;
        border-collapse: collapse;
    }
`;

export const quickActions = css`
    display: flex;
    flex-direction: column;
    gap: 12px;
`;
