/**
 * Salesperson Profile Screen Styles
 */
import { css, Theme } from '@emotion/react';

export const pageContainer = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    max-width: 600px;
    margin: 0 auto;
    
    @media (max-width: 768px) {
        padding: ${theme.spacing[4]};
    }
`;

export const profileHeader = css`
    text-align: center;
    margin-bottom: 32px;
`;

export const logoImage = css`
    height: 92px;
    margin-bottom: 18px;
`;

export const userName = css`
    font-size: 20px;
    font-weight: 700;
    color: #1a1a1a;
    margin-bottom: 4px;
`;

export const userRole = css`
    font-size: 15px;
    font-weight: 500;
    color: #bdbdbd;
    text-transform: capitalize;
`;

export const profileCard = css`
    background: white;
    border-radius: 12px;
    padding: 18px;
    margin-bottom: 12px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
`;

export const avatarPlaceholder = css`
    width: 64px;
    height: 64px;
    border-radius: 50%;
    background: #e0e7ff;
    color: #4338ca;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    font-weight: 700;
    margin: 0 auto 16px auto;
`;

export const cardLabel = css`
    font-size: 14px;
    font-weight: 500;
    color: #bdbdbd;
    margin-bottom: 4px;
`;

export const cardValue = (isBold: boolean) => css`
    font-size: 16px;
    font-weight: ${isBold ? 700 : 500};
    color: #1a1a1a;
`;

export const actionsContainer = css`
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-top: 24px;
`;

export const actionButton = (variant: 'primary' | 'danger') => css`
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px 24px;
    font-size: 15px;
    font-weight: 600;
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    transition: opacity 0.2s, transform 0.2s;
    
    ${variant === 'primary' && `
        background: #3B82F6;
        
        &:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
    `}
    
    ${variant === 'danger' && `
        background: #EF4444;
        
        &:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
    `}
    
    &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        transform: none;
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
`;

// Modal styles
export const modalOverlay = css`
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 20px;
`;

export const modalContent = css`
    background: white;
    border-radius: 16px;
    padding: 24px;
    width: 100%;
    max-width: 400px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
`;

export const modalTitle = css`
    font-size: 20px;
    font-weight: 700;
    margin-bottom: 20px;
    color: #1a1a1a;
`;

export const formField = css`
    margin-bottom: 16px;
`;

export const formLabel = css`
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #666;
    margin-bottom: 6px;
`;

export const formInput = (theme: Theme) => css`
    width: 100%;
    padding: 12px;
    font-size: 15px;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    outline: none;
    transition: border-color 0.2s;
    
    &:focus {
        border-color: ${theme.colors.primary};
    }
`;

export const modalActions = css`
    display: flex;
    gap: 12px;
    margin-top: 24px;
`;

export const modalButton = (variant: 'cancel' | 'submit') => css`
    flex: 1;
    padding: 12px;
    font-size: 15px;
    font-weight: 600;
    border-radius: 8px;
    cursor: pointer;
    transition: opacity 0.2s;
    
    ${variant === 'cancel' && `
        background: transparent;
        border: 1px solid #e5e7eb;
        color: #666;
        
        &:hover {
            background: #f5f5f5;
        }
    `}
    
    ${variant === 'submit' && `
        background: #3B82F6;
        border: none;
        color: white;
        
        &:hover {
            opacity: 0.9;
        }
    `}
    
    &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
`;

export const toast = (type: 'success' | 'error') => css`
    position: fixed;
    bottom: 24px;
    left: 50%;
    transform: translateX(-50%);
    padding: 12px 24px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    color: white;
    z-index: 1001;
    animation: slideUp 0.3s ease;
    
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateX(-50%) translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
    }
    
    ${type === 'success' && `background: #10B981;`}
    ${type === 'error' && `background: #EF4444;`}
`;
