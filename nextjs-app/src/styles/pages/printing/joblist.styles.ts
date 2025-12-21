/**
 * Printing Job List Styles
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

export const grid = css`
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
`;

export const jobCard = (status: string) => css`
    background: white;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    display: flex;
    flex-direction: column;
    border-top: 4px solid ${status === 'ready_for_print' ? '#3B82F6' :
        status === 'printing' ? '#8B5CF6' :
            status === 'completed' ? '#10B981' : '#9CA3AF'
    };

    .header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 12px;
        
        h3 { margin: 0; font-size: 18px; color: #1B2330; }
        span { 
            font-size: 12px; 
            padding: 4px 8px; 
            background: #F3F4F6; 
            border-radius: 6px; 
            color: #4B5563;
            font-weight: 500;
        }
    }

    .details {
        flex: 1;
        margin-bottom: 20px;
        
        p { margin: 0 0 8px; font-size: 14px; color: #6B7280; }
        strong { color: #374151; font-weight: 500; }
    }

    .actions {
        display: flex;
        gap: 8px;
    }
`;

export const button = (variant: 'primary' | 'success' | 'danger') => css`
    flex: 1;
    padding: 10px;
    border-radius: 8px;
    border: none;
    font-weight: 600;
    font-size: 13px;
    cursor: pointer;
    transition: opacity 0.2s;
    
    background: ${variant === 'primary' ? '#3B82F6' :
        variant === 'success' ? '#10B981' : '#EF4444'
    };
    color: white;

    &:hover { opacity: 0.9; }
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
