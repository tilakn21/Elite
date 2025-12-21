/**
 * Production Update Status Styles
 */
import { css, Theme } from '@emotion/react';

export const pageContainer = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    max-width: 800px;
    margin: 0 auto;

    @media (max-width: 768px) {
        padding: ${theme.spacing[4]};
    }
`;

export const header = css`
    margin-bottom: 24px;
    h1 { margin: 0 0 8px; font-size: 24px; color: #1B2330; }
`;

export const jobCard = css`
    background: white;
    padding: 24px;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
    margin-bottom: 20px;
    
    .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        
        h3 { margin: 0; font-size: 18px; color: #1B2330; }
        span { font-size: 13px; color: #6B7280; }
    }
    
    .status-row {
        display: flex;
        gap: 12px;
        align-items: center;
        flex-wrap: wrap;
    }
`;

export const statusButton = (isActive: boolean, color: string) => css`
    padding: 8px 16px;
    border: 1px solid ${isActive ? color : '#E5E7EB'};
    background: ${isActive ? color : 'transparent'};
    color: ${isActive ? 'white' : '#6B7280'};
    border-radius: 20px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
        border-color: ${color};
        color: ${isActive ? 'white' : color};
    }
`;

export const loadingContainer = css`
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 400px;
`;

export const spinnerAnimation = css`
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
    width: 40px; height: 40px;
    border: 3px solid #E5E7EB;
    border-top-color: #4F46E5;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
`;
