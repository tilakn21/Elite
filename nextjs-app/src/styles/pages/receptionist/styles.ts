/**
 * Receptionist Dashboard Styles
 */
import { css, Theme } from '@emotion/react';

export const pageContainer = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    
    @media (max-width: 768px) {
        padding: ${theme.spacing[4]};
    }
`;

export const greeting = css`
    margin-bottom: 24px;
    
    h1 {
        font-size: 24px;
        font-weight: 700;
        color: #1B2330;
        margin: 0 0 4px 0;
    }
    
    p {
        font-size: 14px;
        color: #666;
        margin: 0;
    }
`;

export const statsGrid = css`
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    margin-bottom: 32px;
    
    @media (max-width: 1024px) {
        grid-template-columns: repeat(3, 1fr);
    }
    
    @media (max-width: 600px) {
        grid-template-columns: 1fr;
    }
`;

export const statCard = (color: string) => css`
    background: white;
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    border-left: 4px solid ${color};
    
    h3 {
        font-size: 32px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
    
    p {
        font-size: 14px;
        color: #666;
        margin: 8px 0 0 0;
    }
`;

export const statCardClickable = (color: string) => css`
    background: white;
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    border-left: 4px solid ${color};
    cursor: pointer;
    text-decoration: none;
    display: block;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    
    &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
    }
    
    h3 {
        font-size: 32px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
    
    p {
        font-size: 14px;
        color: #666;
        margin: 8px 0 0 0;
    }
`;

export const mainGrid = css`
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
`;

export const cardHeader = css`
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;
    
    h2 {
        font-size: 16px;
        font-weight: 600;
        color: #1B2330;
        margin: 0;
    }
    
    a {
        font-size: 13px;
        color: #5A6CEA;
        text-decoration: none;
        font-weight: 500;
        
        &:hover {
            text-decoration: underline;
        }
    }
`;

export const jobList = css`
    display: flex;
    flex-direction: column;
    gap: 12px;
    max-height: 300px;
    overflow-y: auto;
`;

export const jobItem = css`
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    background: #F9FAFB;
    border-radius: 10px;
    
    .avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: linear-gradient(135deg, #5A6CEA, #7C3AED);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        font-size: 14px;
    }
    
    .info {
        flex: 1;
        min-width: 0;
        
        .name {
            font-weight: 600;
            color: #1B2330;
            font-size: 14px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .shop {
            font-size: 12px;
            color: #666;
        }
    }
    
    .time {
        font-size: 12px;
        color: #9CA3AF;
    }
`;

export const salespersonList = css`
    display: flex;
    flex-direction: column;
    gap: 10px;
`;

export const salespersonItem = css`
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    background: #F9FAFB;
    border-radius: 10px;
    
    .avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #E5E7EB;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #666;
        font-weight: 600;
        font-size: 14px;
    }
    
    .info {
        flex: 1;
        
        .name {
            font-weight: 600;
            color: #1B2330;
            font-size: 14px;
        }
        
        .jobs {
            font-size: 12px;
            color: #666;
        }
    }
`;

export const statusBadge = (available: boolean) => css`
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 600;
    
    ${available ? `
        background: #D1FAE5;
        color: #059669;
    ` : `
        background: #FEE2E2;
        color: #DC2626;
    `}
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

export const emptyState = css`
    text-align: center;
    padding: 40px 20px;
    color: #9CA3AF;
    font-size: 14px;
`;
