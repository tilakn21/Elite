/**
 * Receptionist New Job Page Styles
 */
import { css, Theme } from '@emotion/react';

export const pageContainer = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    max-width: 900px;
    margin: 0 auto;
    
    @media (max-width: 768px) {
        padding: ${theme.spacing[4]};
    }
`;

export const formCard = css`
    background: white;
    border-radius: 16px;
    padding: 32px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
`;

export const formHeader = css`
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 28px;
    
    h1 {
        font-size: 22px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
`;

export const formSection = css`
    margin-bottom: 28px;
    
    h3 {
        font-size: 15px;
        font-weight: 600;
        color: #1B2330;
        margin: 0 0 16px 0;
        padding-bottom: 8px;
        border-bottom: 1px solid #E5E7EB;
    }
`;

export const formGrid = css`
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    
    @media (max-width: 600px) {
        grid-template-columns: 1fr;
    }
`;

export const formField = css`
    display: flex;
    flex-direction: column;
    gap: 6px;
`;

export const fullWidth = css`
    grid-column: 1 / -1;
`;

export const label = css`
    font-size: 14px;
    font-weight: 500;
    color: #1B2330;
`;

export const input = (hasError: boolean, theme: Theme) => css`
    padding: 12px 14px;
    font-size: 14px;
    border: 1.5px solid ${hasError ? '#EF4444' : '#E5E7EB'};
    border-radius: 10px;
    background: #FAFAFA;
    outline: none;
    transition: border-color 0.2s;
    
    &:focus {
        border-color: ${theme.colors.primary};
        background: white;
    }
    
    &::placeholder {
        color: #9CA3AF;
    }
`;

export const salespersonGrid = css`
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 12px;
`;

export const salespersonOption = (isSelected: boolean, isDisabled: boolean) => css`
    padding: 14px;
    border: 2px solid ${isSelected ? '#5A6CEA' : '#E5E7EB'};
    border-radius: 12px;
    background: ${isSelected ? '#EEF0FF' : 'white'};
    cursor: ${isDisabled ? 'not-allowed' : 'pointer'};
    opacity: ${isDisabled ? 0.5 : 1};
    transition: all 0.2s;
    
    ${!isDisabled && !isSelected && `
        &:hover {
            border-color: #D1D5DB;
            background: #F9FAFB;
        }
    `}
    
    .name {
        font-weight: 600;
        color: #1B2330;
        font-size: 14px;
        margin-bottom: 4px;
    }
    
    .meta {
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: 12px;
        color: #666;
    }
`;

export const statusBadge = (available: boolean) => css`
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: 600;
    
    ${available ? `
        background: #D1FAE5;
        color: #059669;
    ` : `
        background: #FEE2E2;
        color: #DC2626;
    `}
`;

export const buttonRow = css`
    display: flex;
    gap: 12px;
    margin-top: 32px;
    
    @media (max-width: 600px) {
        flex-direction: column;
    }
`;

export const button = (variant: 'primary' | 'secondary') => css`
    flex: 1;
    padding: 14px 24px;
    font-size: 15px;
    font-weight: 600;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.2s;
    
    ${variant === 'primary' && `
        background: #5A6CEA;
        color: white;
        border: none;
        
        &:hover:not(:disabled) {
            background: #4A5CD4;
        }
    `}
    
    ${variant === 'secondary' && `
        background: white;
        color: #666;
        border: 1px solid #E5E7EB;
        
        &:hover:not(:disabled) {
            background: #F9FAFB;
        }
    `}
    
    &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
`;

export const errorText = css`
    color: #EF4444;
    font-size: 12px;
`;

export const toast = (type: 'success' | 'error') => css`
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%);
    padding: 14px 24px;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 500;
    color: white;
    z-index: 1001;
    animation: slideUp 0.3s ease;
    
    @keyframes slideUp {
        from { opacity: 0; transform: translateX(-50%) translateY(20px); }
        to { opacity: 1; transform: translateX(-50%) translateY(0); }
    }
    
    ${type === 'success' && `background: #10B981;`}
    ${type === 'error' && `background: #EF4444;`}
`;
