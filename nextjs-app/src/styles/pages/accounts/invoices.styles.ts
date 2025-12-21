/**
 * Accounts Invoices Page Styles
 */
import { css, Theme } from '@emotion/react';

export const pageContainer = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    max-width: 1200px;
    margin: 0 auto;

    @media (max-width: 768px) {
        padding: ${theme.spacing[4]};
    }
`;

export const header = css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    
    h1 { margin: 0; font-size: 24px; color: #1B2330; }
`;

export const tabs = css`
    display: flex;
    gap: 8px;
    margin-bottom: 24px;
    overflow-x: auto;
    padding-bottom: 4px;
`;

export const tab = (isActive: boolean) => css`
    padding: 10px 20px;
    border-radius: 20px;
    background: ${isActive ? '#1B2330' : 'white'};
    color: ${isActive ? 'white' : '#6B7280'};
    border: 1px solid ${isActive ? '#1B2330' : '#E5E7EB'};
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    white-space: nowrap;
    
    &:hover {
        background: ${isActive ? '#1B2330' : '#F9FAFB'};
    }
`;

export const table = css`
    width: 100%;
    border-collapse: collapse;
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);

    th {
        text-align: left;
        padding: 16px 24px;
        background: #F9FAFB;
        color: #6B7280;
        font-weight: 600;
        font-size: 13px;
        text-transform: uppercase;
    }

    td {
        padding: 16px 24px;
        border-top: 1px solid #E5E7EB;
        color: #374151;
        font-size: 15px;
    }

    tr:hover td {
        background: #F9FAFB;
    }
`;

export const statusBadge = (status: string) => css`
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    text-transform: capitalize;
    
    background: ${status === 'paid' ? '#DEF7EC' :
        status === 'pending' ? '#FEF3C7' : '#FEE2E2'
    };
    color: ${status === 'paid' ? '#03543F' :
        status === 'pending' ? '#92400E' : '#991B1B'
    };
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
