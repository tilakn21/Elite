/**
 * Salesperson Reimbursement Screen Styles
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

export const formCard = css`
    background: white;
    border-radius: 16px;
    padding: 32px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
    
    @media (max-width: 768px) {
        padding: 20px;
    }
`;

export const formHeader = css`
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 32px;
    
    svg {
        color: #1B2330;
    }
    
    h1 {
        font-size: 22px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
    
    @media (max-width: 768px) {
        margin-bottom: 20px;
        
        h1 {
            font-size: 18px;
        }
    }
`;

export const formGrid = css`
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    
    @media (max-width: 768px) {
        grid-template-columns: 1fr;
        gap: 16px;
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
    padding: 12px 16px;
    font-size: 14px;
    border: 1.5px solid ${hasError ? '#EF4444' : '#E0E0E0'};
    border-radius: 12px;
    background: #F7F7F9;
    outline: none;
    transition: border-color 0.2s;
    
    &:focus {
        border-color: ${theme.colors.primary};
    }
    
    &::placeholder {
        color: #BDBDBD;
    }
    
    &:read-only {
        background: #EFEFEF;
        cursor: not-allowed;
    }
`;

export const textarea = (hasError: boolean, theme: Theme) => css`
    ${input(hasError, theme)};
    min-height: 80px;
    resize: vertical;
`;

export const uploadArea = (hasError: boolean) => css`
    height: 150px;
    background: #EDEFF1;
    border: 1.5px dashed ${hasError ? '#EF4444' : '#E0E0E0'};
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: border-color 0.2s, background 0.2s;
    
    &:hover {
        background: #E5E7EB;
        border-color: #BDBDBD;
    }
    
    p {
        color: #BDBDBD;
        font-size: 14px;
        margin: 0;
    }
    
    svg {
        color: #BDBDBD;
        margin-bottom: 8px;
    }
`;

export const uploadPreview = css`
    height: 150px;
    border-radius: 12px;
    overflow: hidden;
    position: relative;
    
    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    
    button {
        position: absolute;
        top: 8px;
        right: 8px;
        background: rgba(0, 0, 0, 0.6);
        color: white;
        border: none;
        border-radius: 50%;
        width: 28px;
        height: 28px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        
        &:hover {
            background: rgba(0, 0, 0, 0.8);
        }
    }
`;

export const submitButton = css`
    width: 100%;
    padding: 16px;
    font-size: 16px;
    font-weight: 600;
    color: white;
    background: #5C67F2;
    border: none;
    border-radius: 12px;
    cursor: pointer;
    margin-top: 24px;
    transition: opacity 0.2s, transform 0.2s;
    
    &:hover:not(:disabled) {
        opacity: 0.9;
        transform: translateY(-1px);
    }
    
    &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
`;

export const statusMessage = (isSuccess: boolean) => css`
    margin-top: 16px;
    padding: 16px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    
    ${isSuccess ? `
        background: rgba(16, 185, 129, 0.1);
        border: 1px solid #10B981;
        color: #10B981;
    ` : `
        background: rgba(239, 68, 68, 0.1);
        border: 1px solid #EF4444;
        color: #EF4444;
    `}
`;

export const errorText = css`
    color: #EF4444;
    font-size: 12px;
    margin-top: 4px;
`;
