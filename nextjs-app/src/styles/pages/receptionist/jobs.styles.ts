/**
 * Receptionist Jobs List Page Styles
 */
import { css, Theme } from '@emotion/react';
import type { JobRequestStatus } from '@/types/receptionist';

export const pageContainer = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    
    @media (max-width: 768px) {
        padding: ${theme.spacing[4]};
    }
`;

export const header = css`
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
    gap: 16px;
    flex-wrap: wrap;
    
    h1 {
        font-size: 22px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
`;

export const controls = css`
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
`;

export const searchInput = (theme: Theme) => css`
    padding: 10px 14px;
    padding-left: 38px;
    font-size: 14px;
    border: 1px solid #E5E7EB;
    border-radius: 10px;
    background: white;
    min-width: 240px;
    outline: none;
    
    &:focus {
        border-color: ${theme.colors.primary};
    }
    
    @media (max-width: 600px) {
        min-width: 100%;
    }
`;

export const searchWrapper = css`
    position: relative;
    
    svg {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        color: #9CA3AF;
        width: 18px;
        height: 18px;
    }
`;

export const filterSelect = css`
    padding: 10px 14px;
    font-size: 14px;
    border: 1px solid #E5E7EB;
    border-radius: 10px;
    background: white;
    cursor: pointer;
    min-width: 140px;
`;

export const tableCard = css`
    background: white;
    border-radius: 16px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
    overflow: hidden;
`;

export const table = css`
    width: 100%;
    border-collapse: collapse;
    
    th, td {
        padding: 14px 16px;
        text-align: left;
        border-bottom: 1px solid #E5E7EB;
    }
    
    th {
        font-size: 12px;
        font-weight: 600;
        color: #6B7280;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        background: #F9FAFB;
    }
    
    td {
        font-size: 14px;
        color: #1B2330;
    }
    
    tr:last-child td {
        border-bottom: none;
    }
    
    tr:hover td {
        background: #FAFAFA;
    }
`;

export const customerCell = css`
    display: flex;
    align-items: center;
    gap: 12px;
    
    .avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: linear-gradient(135deg, #5A6CEA, #7C3AED);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        font-size: 13px;
        flex-shrink: 0;
    }
    
    .info {
        .name {
            font-weight: 600;
        }
        
        .shop {
            font-size: 12px;
            color: #6B7280;
        }
    }
`;

export const statusBadge = (status: JobRequestStatus) => css`
    display: inline-block;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
    
    ${status === 'pending' && `
        background: #FEF3C7;
        color: #D97706;
    `}
    
    ${status === 'approved' && `
        background: #DBEAFE;
        color: #2563EB;
    `}
    
    ${status === 'completed' && `
        background: #D1FAE5;
        color: #059669;
    `}
    
    ${status === 'declined' && `
        background: #FEE2E2;
        color: #DC2626;
    `}
`;

export const emptyState = css`
    text-align: center;
    padding: 60px 20px;
    color: #9CA3AF;
    
    h3 {
        font-size: 16px;
        color: #6B7280;
        margin: 0 0 8px 0;
    }
    
    p {
        margin: 0;
    }
`;

export const loadingContainer = css`
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 60px 20px;
`;

export const spinnerAnimation = css`
    @keyframes spin {
        to { transform: rotate(360deg); }
    }
    
    width: 36px;
    height: 36px;
    border: 3px solid #e5e7eb;
    border-top-color: #5A6CEA;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
`;

export const mobileCard = css`
    display: none;
    flex-direction: column;
    gap: 12px;
    padding: 16px;
    
    @media (max-width: 768px) {
        display: flex;
    }
`;

export const mobileJobItem = css`
    background: white;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    
    .header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 12px;
    }
    
    .customer {
        font-weight: 600;
        color: #1B2330;
        margin-bottom: 2px;
    }
    
    .shop {
        font-size: 13px;
        color: #6B7280;
    }
    
    .meta {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        font-size: 12px;
        color: #6B7280;
        
        span {
            display: flex;
            align-items: center;
            gap: 4px;
        }
    }
`;

export const desktopTable = css`
    @media (max-width: 768px) {
        display: none;
    }
`;

// Assign button styles
export const assignButton = css`
    padding: 6px 14px;
    font-size: 13px;
    font-weight: 600;
    background: #5A6CEA;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.2s ease;
    
    &:hover {
        background: #4A5CD9;
    }
`;

export const assignedText = css`
    color: #9CA3AF;
    font-size: 13px;
`;

export const assignButtonMobile = css`
    margin-top: 12px;
    width: 100%;
    padding: 10px 14px;
    font-size: 14px;
    font-weight: 600;
    background: #5A6CEA;
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    
    &:hover {
        background: #4A5CD9;
    }
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
    width: 100%;
    max-width: 480px;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
`;

export const modalHeader = css`
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 24px;
    border-bottom: 1px solid #E5E7EB;
    
    h2 {
        font-size: 18px;
        font-weight: 700;
        color: #1B2330;
        margin: 0;
    }
`;

export const closeButton = css`
    background: none;
    border: none;
    cursor: pointer;
    padding: 4px;
    color: #6B7280;
    
    svg {
        width: 20px;
        height: 20px;
    }
    
    &:hover {
        color: #1B2330;
    }
`;

export const modalBody = css`
    padding: 20px 24px;
`;

export const jobInfo = css`
    font-size: 15px;
    color: #1B2330;
    margin: 0 0 4px 0;
`;

export const dateInfo = css`
    font-size: 13px;
    color: #6B7280;
    margin: 0 0 20px 0;
`;

export const salespersonTitle = css`
    font-size: 14px;
    font-weight: 600;
    color: #1B2330;
    margin: 0 0 12px 0;
`;

export const salespersonList = css`
    display: flex;
    flex-direction: column;
    gap: 8px;
    max-height: 260px;
    overflow-y: auto;
`;

export const salespersonOption = (selected: boolean, disabled: boolean) => css`
    padding: 14px;
    border-radius: 10px;
    border: 2px solid ${selected ? '#5A6CEA' : '#E5E7EB'};
    background: ${selected ? '#F0F2FF' : disabled ? '#F9FAFB' : 'white'};
    cursor: ${disabled ? 'not-allowed' : 'pointer'};
    opacity: ${disabled ? 0.6 : 1};
    transition: all 0.2s ease;
    
    ${!disabled && !selected && `
        &:hover {
            border-color: #5A6CEA;
        }
    `}
    
    .name {
        font-weight: 600;
        color: #1B2330;
        margin-bottom: 4px;
    }
    
    .meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 12px;
        color: #6B7280;
    }
`;

export const availabilityBadge = (available: boolean) => css`
    padding: 3px 8px;
    border-radius: 10px;
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

export const modalLoading = css`
    display: flex;
    justify-content: center;
    padding: 40px 0;
`;

export const modalFooter = css`
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    padding: 16px 24px;
    border-top: 1px solid #E5E7EB;
`;

export const cancelButton = css`
    padding: 10px 20px;
    font-size: 14px;
    font-weight: 600;
    background: white;
    color: #6B7280;
    border: 1px solid #E5E7EB;
    border-radius: 10px;
    cursor: pointer;
    
    &:hover {
        background: #F9FAFB;
    }
`;

export const confirmButton = css`
    padding: 10px 24px;
    font-size: 14px;
    font-weight: 600;
    background: #5A6CEA;
    color: white;
    border: none;
    border-radius: 10px;
    cursor: pointer;
    
    &:hover:not(:disabled) {
        background: #4A5CD9;
    }
    
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
    padding: 14px 24px;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 500;
    z-index: 1100;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    animation: slideUp 0.3s ease;
    
    ${type === 'success' ? `
        background: #059669;
        color: white;
    ` : `
        background: #DC2626;
        color: white;
    `}
    
    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateX(-50%) translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
    }
`;
