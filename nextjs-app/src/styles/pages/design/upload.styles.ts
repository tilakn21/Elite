/**
 * Design Upload Draft Styles
 */
import { css, Theme } from '@emotion/react';

export const pageContainer = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    max-width: 1000px;
    margin: 0 auto;

    @media (max-width: 768px) {
        padding: ${theme.spacing[4]};
    }
`;

export const header = css`
    margin-bottom: 32px;
    
    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: #6B7280;
        font-size: 14px;
        margin-bottom: 16px;
        cursor: pointer;
        
        &:hover {
            color: #1B2330;
        }
    }

    h1 {
        font-size: 24px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
`;

export const grid = css`
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 32px;
    
    @media (max-width: 900px) {
        grid-template-columns: 1fr;
    }
`;

export const card = css`
    background: white;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    margin-bottom: 24px;

    h2 {
        font-size: 18px;
        font-weight: 600;
        color: #1B2330;
        margin: 0 0 20px 0;
        padding-bottom: 12px;
        border-bottom: 1px solid #E5E7EB;
    }
`;

export const detailRow = css`
    display: flex;
    justify-content: space-between;
    padding: 12px 0;
    border-bottom: 1px solid #F3F4F6;
    
    &:last-child {
        border-bottom: none;
    }
    
    .label {
        font-size: 14px;
        color: #6B7280;
        font-weight: 500;
    }
    
    .value {
        font-size: 14px;
        color: #1B2330;
        font-weight: 600;
        text-align: right;
    }
`;

export const imagesGrid = css`
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
    gap: 12px;
    
    .image-box {
        aspect-ratio: 1;
        border-radius: 8px;
        background: #F3F4F6;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        border: 1px solid #E5E7EB;
        
        img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        span {
            font-size: 12px;
            color: #9CA3AF;
        }
    }
`;

export const uploadArea = (isDragging: boolean) => css`
    border: 2px dashed ${isDragging ? '#4F46E5' : '#E5E7EB'};
    background: ${isDragging ? '#EEF2FF' : '#F9FAFB'};
    border-radius: 12px;
    padding: 40px 20px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
        border-color: #4F46E5;
        background: #EEF2FF;
    }
    
    .icon {
        font-size: 32px;
        color: #4F46E5;
        margin-bottom: 12px;
    }
    
    p {
        margin: 0 0 4px 0;
        font-weight: 500;
        color: #1B2330;
    }
    
    span {
        font-size: 12px;
        color: #6B7280;
    }
`;

export const button = (variant: 'primary' | 'secondary' = 'primary') => css`
    width: 100%;
    padding: 12px;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    border: none;
    transition: all 0.2s;
    
    ${variant === 'primary' ? `
        background: #4F46E5;
        color: white;
        &:hover { background: #4338CA; }
        &:disabled { background: #E0E7FF; cursor: not-allowed; }
    ` : `
        background: white;
        color: #4B5563;
        border: 1px solid #E5E7EB;
        &:hover { background: #F9FAFB; }
    `}
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
