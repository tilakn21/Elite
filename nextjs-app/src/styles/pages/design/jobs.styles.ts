/**
 * Design Job List Styles
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
    margin-bottom: 32px;
    flex-wrap: wrap;
    gap: 16px;

    h1 {
        font-size: 24px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
`;

export const controls = css`
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
`;

export const searchInput = (theme: Theme) => css`
    padding: 10px 14px;
    padding-left: 38px;
    font-size: 14px;
    border: 1px solid #E5E7EB;
    border-radius: 10px;
    background: white;
    min-width: 240px;
    outline: none;
    
    &:focus {
        border-color: ${theme.colors.primary};
        box-shadow: 0 0 0 2px ${theme.colors.primary}20;
    }
`;

export const searchWrapper = css`
    position: relative;
    
    svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        color: #9CA3AF;
        width: 18px;
        height: 18px;
    }
`;

export const tabContainer = css`
    display: flex;
    gap: 4px;
    background: #F3F4F6;
    padding: 4px;
    border-radius: 12px;
    margin-bottom: 24px;
    width: fit-content;
`;

export const tab = (isActive: boolean) => css`
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    background: ${isActive ? 'white' : 'transparent'};
    color: ${isActive ? '#1B2330' : '#6B7280'};
    box-shadow: ${isActive ? '0 1px 3px rgba(0,0,0,0.1)' : 'none'};

    &:hover {
        color: #1B2330;
    }
`;

export const jobGrid = css`
    display: flex;
    flex-direction: column;
    gap: 16px;
`;

export const jobCard = css`
    background: white;
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    display: grid;
    grid-template-columns: auto 1fr auto;
    gap: 24px;
    align-items: center;
    transition: all 0.2s;
    cursor: pointer;

    &:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.08);
    }

    @media (max-width: 768px) {
        grid-template-columns: 1fr;
        gap: 16px;
    }
`;

export const jobIcon = css`
    width: 56px;
    height: 56px;
    border-radius: 14px;
    background: #EEF2FF;
    color: #4F46E5;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    font-weight: 700;
`;

export const jobInfo = css`
    .title-row {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 6px;
        flex-wrap: wrap;
    }

    h3 {
        font-size: 16px;
        font-weight: 600;
        color: #1B2330;
        margin: 0;
    }

    .meta {
        display: flex;
        gap: 16px;
        font-size: 13px;
        color: #6B7280;
        align-items: center;

        svg {
            margin-right: 4px;
            width: 14px;
            height: 14px;
        }
    }
`;

export const statusBadge = (status: string) => css`
    padding: 4px 10px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.02em;

    ${status === 'pending' && `background: #FEF3C7; color: #D97706;`}
    ${status === 'in_progress' && `background: #DBEAFE; color: #2563EB;`}
    ${status === 'draft_uploaded' && `background: #E0E7FF; color: #4F46E5;`}
    ${status === 'changes_requested' && `background: #FEE2E2; color: #DC2626;`}
    ${status === 'approved' && `background: #D1FAE5; color: #059669;`}
    ${status === 'completed' && `background: #F3F4F6; color: #374151;`}
`;

export const actionButton = css`
    padding: 10px 20px;
    background: #4F46E5;
    color: white;
    border: none;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;

    &:hover {
        background: #4338CA;
    }

    @media (max-width: 768px) {
        width: 100%;
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
    
    width: 40px;
    height: 40px;
    border: 3px solid #E5E7EB;
    border-top-color: #4F46E5;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
`;

export const emptyState = css`
    text-align: center;
    padding: 60px 20px;
    color: #9CA3AF;
`;
