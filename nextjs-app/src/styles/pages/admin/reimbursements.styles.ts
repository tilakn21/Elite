/**
 * Admin Reimbursements Page Styles
 */
import { css, Theme } from '@emotion/react';

export const container = (theme: Theme) => css`
    display: flex;
    flex-direction: column;
    gap: ${theme.spacing[6]};
`;

export const amount = css`
    font-weight: 600;
    color: #111827;
`;

// Modal Styles
export const modalContent = css`
    display: flex;
    flex-direction: column;
    gap: 16px;
`;

export const detailRow = css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 12px;
    border-bottom: 1px solid #f3f4f6;

    &:last-child {
        border-bottom: none;
    }
`;

export const label = css`
    font-weight: 600;
    color: #4b5563;
    font-size: 14px;
`;

export const value = css`
    color: #111827;
    font-size: 14px;
    font-weight: 500;
`;

export const receiptLink = css`
    color: #3b82f6;
    text-decoration: none;
    font-weight: 500;
    
    &:hover {
        text-decoration: underline;
    }
`;

export const remarksContainer = css`
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: 8px;
    padding: 12px;
    background-color: #f9fafb;
    border-radius: 8px;

    span {
        font-weight: 600;
        color: #4b5563;
        font-size: 13px;
    }

    p {
        margin: 0;
        color: #374151;
        font-size: 14px;
        line-height: 1.5;
    }
`;
