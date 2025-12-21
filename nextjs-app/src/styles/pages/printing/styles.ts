/**
 * Printing Dashboard Styles
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

export const welcomeSection = css`
    margin-bottom: 32px;
    
    h1 {
        font-size: 28px;
        font-weight: 700;
        color: #1B2330;
        margin: 0 0 8px 0;
    }

    p {
        color: #6B7280;
        font-size: 16px;
        margin: 0;
    }
`;

export const statsGrid = css`
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 24px;
    margin-bottom: 40px;
`;

export const statCard = (color: string) => css`
    background: white;
    padding: 24px;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 140px;
    transition: transform 0.2s;
    border-left: 5px solid ${color};

    &:hover {
        transform: translateY(-4px);
    }

    .label {
        font-size: 15px;
        color: #6B7280;
        font-weight: 500;
    }

    .value {
        font-size: 36px;
        font-weight: 700;
        color: #1B2330;
    }
`;

export const inkContainer = css`
    display: flex;
    gap: 12px;
    margin-top: 12px;
`;

export const inkLevel = (color: string, level: number) => css`
    flex: 1;
    height: 8px;
    background: #E5E7EB;
    border-radius: 4px;
    overflow: hidden;
    position: relative;

    &::after {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        width: ${level}%;
        background: ${color};
        transition: width 1s ease-out;
    }
`;

export const actionGrid = css`
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 24px;
`;

export const actionCard = () => css`
    background: white;
    padding: 32px;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 24px;
    border: 1px solid transparent;

    &:hover {
        border-color: #5A6CEA;
        transform: translateY(-4px);
        box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
    }

    .icon-box {
        width: 64px;
        height: 64px;
        border-radius: 16px;
        background: #F3F4F6;
        color: #374151;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 28px;
    }

    .info {
        flex: 1;

        h3 {
            font-size: 18px;
            font-weight: 600;
            color: #1B2330;
            margin: 0 0 4px 0;
        }

        p {
            font-size: 14px;
            color: #6B7280;
            margin: 0;
        }
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
    border-top-color: #4B5563;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
`;
