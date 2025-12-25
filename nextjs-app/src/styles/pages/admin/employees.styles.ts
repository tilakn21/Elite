/**
 * Admin Employees Page Styles
 */
import { css, Theme } from '@emotion/react';

export const container = (theme: Theme) => css`
    display: flex;
    flex-direction: column;
    gap: ${theme.spacing[6]};
    padding-bottom: 40px;
`;

export const header = css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
`;

export const title = (theme: Theme) => css`
    font-size: 28px;
    font-weight: 800;
    color: ${theme.colors.textPrimary};
    letter-spacing: -0.5px;
`;

export const subtitle = css`
    font-size: 14px;
    color: #6B7280;
    margin-top: 4px;
`;

export const controls = css`
    display: flex;
    gap: 16px;
    align-items: center;
    flex-wrap: wrap;
`;

export const searchInput = css`
    padding: 10px 16px;
    border: 1px solid #E5E7EB;
    border-radius: 8px;
    font-size: 14px;
    width: 250px;
    transition: all 0.2s;
    &:focus {
        border-color: #6366F1;
        outline: none;
        box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
    }
`;

export const grid = css`
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
    margin-top: 24px;
`;

export const card = css`
    background: white;
    border-radius: 16px;
    padding: 24px;
    border: 1px solid #E5E7EB;
    transition: all 0.2s ease;
    display: flex;
    flex-direction: column;
    gap: 16px;
    position: relative;
    overflow: hidden;

    &:hover {
        transform: translateY(-2px);
        box-shadow: 0 12px 24px -8px rgba(0, 0, 0, 0.08);
        border-color: #D1D5DB;
    }
`;

export const cardHeader = css`
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
`;

export const avatar = (color: string) => css`
    width: 56px;
    height: 56px;
    border-radius: 16px;
    background: ${color}15;
    color: ${color};
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    font-weight: 700;
    border: 1px solid ${color}30;
`;

export const statusBadge = (isAvailable: boolean) => css`
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    background: ${isAvailable ? '#DCFCE7' : '#F3F4F6'};
    color: ${isAvailable ? '#166534' : '#6B7280'};
    border: 1px solid ${isAvailable ? '#bbf7d0' : '#e5e7eb'};
`;

export const cardBody = css`
    display: flex;
    flex-direction: column;
    gap: 4px;
`;

export const name = css`
    font-size: 18px;
    font-weight: 700;
    color: #111827;
`;

export const role = css`
    font-size: 13px;
    color: #6B7280;
    font-weight: 500;
    text-transform: capitalize;
    display: flex;
    align-items: center;
    gap: 6px;
`;

export const infoRow = css`
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    color: #4B5563;
    padding: 8px 0;

    &:not(:first-of-type) {
        border-top: 1px solid #F3F4F6;
    }

    & svg {
        color: #9CA3AF;
        width: 16px;
        height: 16px;
        flex-shrink: 0;
    }
`;

export const cardFooter = css`
    display: flex;
    gap: 8px;
    width: 100%;
    margin-top: auto;
    padding-top: 16px;
`;

export const actionButton = (variant: 'primary' | 'secondary' | 'danger') => {
    const baseStyles = css`
        flex: 1;
        padding: 8px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        border: none;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
    `;

    const variantStyles = {
        primary: css`
            background: #EEF2FF;
            color: #4F46E5;
            &:hover { background: #E0E7FF; }
        `,
        secondary: css`
            background: #F9FAFB;
            color: #374151;
            border: 1px solid #E5E7EB;
            &:hover { background: #F3F4F6; border-color: #D1D5DB; }
        `,
        danger: css`
            background: #FEF2F2;
            color: #DC2626;
            &:hover { background: #FEE2E2; }
        `,
    };

    return css`
        ${baseStyles}
        ${variantStyles[variant]}
    `;
};


export const form = css`
    display: flex;
    flex-direction: column;
    gap: 20px;
    padding: 8px 0;
`;

export const formSection = css`
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
`;

export const emptyState = css`
    grid-column: 1 / -1;
    text-align: center;
    padding: 60px;
    background: #F9FAFB;
    border-radius: 16px;
    border: 2px dashed #E5E7EB;
    color: #6B7280;
`;
