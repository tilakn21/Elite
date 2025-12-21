/**
 * Production Assign Labour Styles
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
    margin-bottom: 24px;
    h1 { margin: 0; font-size: 24px; color: #1B2330; }
    p { margin: 4px 0 0; color: #6B7280; font-size: 14px; }
`;

export const grid = css`
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    
    @media (max-width: 900px) {
        grid-template-columns: 1fr;
    }
`;

export const card = css`
    background: white;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    height: fit-content;

    h2 {
        font-size: 18px;
        font-weight: 600;
        margin: 0 0 16px 0;
        color: #1B2330;
    }
`;

export const jobItem = (isSelected: boolean) => css`
    padding: 16px;
    border: 2px solid ${isSelected ? '#4F46E5' : '#E5E7EB'};
    border-radius: 12px;
    background: ${isSelected ? '#EEF2FF' : '#F9FAFB'};
    margin-bottom: 12px;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
        border-color: #4F46E5;
    }
    
    h3 { margin: 0 0 4px; font-size: 15px; font-weight: 600; }
    p { margin: 0; font-size: 13px; color: #6B7280; }
`;

export const workerItem = (isSelected: boolean, isAvailable: boolean) => css`
    padding: 12px;
    border: 2px solid ${isSelected ? '#10B981' : '#E5E7EB'};
    border-radius: 12px;
    background: ${isSelected ? '#ECFDF5' : 'white'};
    margin-bottom: 12px;
    cursor: ${isAvailable ? 'pointer' : 'not-allowed'};
    opacity: ${isAvailable ? 1 : 0.6};
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    &:hover {
        border-color: ${isAvailable ? '#10B981' : '#E5E7EB'};
    }
    
    .name { font-weight: 500; font-size: 14px; }
    .role { font-size: 12px; color: #6B7280; text-transform: capitalize; }
    .status { 
        font-size: 11px; 
        padding: 2px 8px; 
        border-radius: 10px;
        background: ${isAvailable ? '#D1FAE5' : '#FEE2E2'};
        color: ${isAvailable ? '#059669' : '#DC2626'};
    }
`;

export const assignButton = css`
    width: 100%;
    padding: 14px;
    background: #4F46E5;
    color: white;
    font-weight: 600;
    border: none;
    border-radius: 12px;
    cursor: pointer;
    margin-top: 24px;
    transition: background 0.2s;
    
    &:hover:not(:disabled) { background: #4338CA; }
    &:disabled { opacity: 0.5; cursor: not-allowed; }
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
