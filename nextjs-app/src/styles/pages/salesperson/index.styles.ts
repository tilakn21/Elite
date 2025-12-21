/**
 * Salesperson Dashboard - Home Screen Styles
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

export const searchContainer = css`
    margin-bottom: 24px;
`;

export const searchInput = (theme: Theme) => css`
    width: 100%;
    padding: 12px 16px;
    padding-left: 44px;
    font-size: 15px;
    border: none;
    border-radius: 12px;
    background: ${theme.colors.surface};
    color: ${theme.colors.textPrimary};
    outline: none;
    transition: box-shadow 0.2s;
    
    &:focus {
        box-shadow: 0 0 0 2px ${theme.colors.primary};
    }
    
    &::placeholder {
        color: ${theme.colors.textSecondary};
    }
`;

export const searchWrapper = css`
    position: relative;
    
    svg {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        color: #aaa;
    }
`;

export const jobsList = css`
    display: flex;
    flex-direction: column;
    gap: 12px;
`;

export const jobCard = (isClickable: boolean) => css`
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px 20px;
    background: white;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    cursor: ${isClickable ? 'pointer' : 'default'};
    opacity: ${isClickable ? 1 : 0.5};
    transition: transform 0.2s, box-shadow 0.2s;
    
    ${isClickable && `
        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
        }
    `}
`;

export const avatarCircle = (theme: Theme) => css`
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: linear-gradient(135deg, ${theme.colors.primary}, #7C3AED);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: 600;
    font-size: 16px;
    flex-shrink: 0;
`;

export const jobInfo = css`
    flex: 1;
    min-width: 0;
`;

export const customerName = css`
    font-weight: 600;
    font-size: 15px;
    color: #1a1a1a;
    margin-bottom: 4px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
`;

export const jobMeta = css`
    display: flex;
    align-items: center;
    gap: 16px;
    font-size: 13px;
    color: #666;
    flex-wrap: wrap;
`;

export const jobCodeText = css`
    color: #5A6CEA;
    font-weight: 500;
`;

export const statusBadge = (status: 'pending' | 'submitted' | 'completed') => css`
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    flex-shrink: 0;
    
    ${status === 'pending' && `
        background: #FFE3E3;
        color: #D32F2F;
    `}
    
    ${(status === 'submitted' || status === 'completed') && `
        background: #D2F6E7;
        color: #3BB77E;
    `}
`;

export const arrowIcon = css`
    color: #bdbdbd;
    flex-shrink: 0;
`;

export const emptyState = (theme: Theme) => css`
    text-align: center;
    padding: 60px 20px;
    color: ${theme.colors.textSecondary};
    
    svg {
        width: 64px;
        height: 64px;
        margin-bottom: 16px;
        opacity: 0.5;
    }
    
    h3 {
        font-size: 18px;
        margin-bottom: 8px;
        color: ${theme.colors.textPrimary};
    }
`;

export const loadingContainer = css`
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 300px;
`;

export const spinnerAnimation = css`
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
    
    width: 40px;
    height: 40px;
    border: 3px solid #e5e7eb;
    border-top-color: #5A6CEA;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
`;

export const errorMessage = css`
    text-align: center;
    padding: 40px;
    color: #D32F2F;
    background: #FFEBEE;
    border-radius: 12px;
    margin: 20px 0;
`;
