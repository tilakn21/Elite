/**
 * Salesperson Job Details Page Styles
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

export const header = css`
    margin-bottom: 24px;

    h1 {
        font-size: 24px;
        font-weight: 700;
        color: #1B2330;
        margin: 0 0 8px 0;
    }
`;

export const errorMessage = css`
    color: #EF4444;
    text-align: center;
    padding: 40px;
    background: #FEF2F2;
    border-radius: 12px;
`;

export const section = css`
    background: white;
    padding: 32px;
    border-radius: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    border: 1px solid rgba(0, 0, 0, 0.03);
    margin-bottom: 24px;
    transition: transform 0.2s ease;
    
    &:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.06);
    }
`;

export const sectionTitle = css`
    font-size: 18px;
    font-weight: 700;
    color: #111827;
    margin: 0 0 24px 0;
    padding-bottom: 16px;
    border-bottom: 2px solid #F3F4F6;
    letter-spacing: -0.01em;
`;

export const infoGrid = css`
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 24px;
`;

export const infoItem = css`
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding: 16px;
    background: #F9FAFB;
    border-radius: 12px;

    label {
        font-size: 12px;
        font-weight: 600;
        color: #6B7280;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    span {
        font-size: 16px;
        color: #111827;
        font-weight: 600;
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
    gap: 8px;
`;

export const fullWidth = css`
    grid-column: 1 / -1;
`;

export const label = css`
    font-size: 14px;
    font-weight: 500;
    color: #374151;
`;

export const input = (theme: Theme) => css`
    padding: 14px 16px;
    border: 2px solid #E5E7EB;
    border-radius: 12px;
    font-size: 15px;
    font-weight: 500;
    color: #1F2937;
    outline: none;
    transition: all 0.2s ease;
    background: #FAFAFA;

    &:focus {
        border-color: ${theme.colors.primary};
        background: white;
        box-shadow: 0 0 0 4px ${theme.colors.primary}1A;
    }

    &::placeholder {
        color: #9CA3AF;
        font-weight: 400;
    }
`;

export const select = (theme: Theme) => css`
    ${input(theme)};
    background-color: #FAFAFA;
    cursor: pointer;
    appearance: none;
    background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236B7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
    background-position: right 14px center;
    background-repeat: no-repeat;
    background-size: 20px 20px;
    padding-right: 44px;
`;

export const textArea = (theme: Theme) => css`
    ${input(theme)};
    min-height: 100px;
    resize: vertical;
    line-height: 1.5;
`;

export const radioGroup = css`
    display: flex;
    gap: 20px;
    margin-top: 4px;

    label {
        display: flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        font-size: 14px;
        color: #374151;
    }

    input[type="radio"] {
        accent-color: #5A6CEA;
        width: 16px;
        height: 16px;
    }
`;

export const buttonRow = css`
    display: flex;
    gap: 12px;
    margin-top: 32px;
`;

export const button = (variant: 'primary' | 'secondary' = 'primary') => css`
    padding: 14px 24px;
    border-radius: 10px;
    font-weight: 600;
    font-size: 15px;
    cursor: pointer;
    transition: all 0.2s;
    border: none;
    flex: 1;

    ${variant === 'primary' ? `
        background: #5A6CEA;
        color: white;

        &:hover {
            background: #4A5CD4;
        }
    ` : `
        background: white;
        color: #6B7280;
        border: 1px solid #E5E7EB;

        &:hover {
            background: #F9FAFB;
        }
    `}

    &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
`;

export const modalOverlay = css`
    position: fixed;
    inset: 0;
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
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.1);

    h2 {
        margin: 0 0 20px 0;
        font-size: 18px;
        color: #1B2330;
    }
`;

export const modalActions = css`
    display: flex;
    gap: 12px;
    margin-top: 24px;
`;

export const loadingContainer = css`
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 300px;
`;

export const spinner = css`
    width: 40px;
    height: 40px;
    border: 3px solid #E5E7EB;
    border-top-color: #5A6CEA;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;

    @keyframes spin {
        to { transform: rotate(360deg); }
    }
`;
