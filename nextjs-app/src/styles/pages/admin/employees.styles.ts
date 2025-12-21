/**
 * Admin Employees Page Styles
 */
import { css, Theme } from '@emotion/react';

export const container = (theme: Theme) => css`
    display: flex;
    flex-direction: column;
    gap: ${theme.spacing[6]};
`;

export const header = css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    flex-wrap: wrap;
    gap: 16px;
`;

export const title = (theme: Theme) => css`
    font-size: 24px;
    font-weight: 700;
    color: ${theme.colors.textPrimary};
`;

export const form = css`
    display: flex;
    flex-direction: column;
    gap: 16px;
`;

export const actions = css`
    display: flex;
    gap: 8px;
    justify-content: flex-end;
`;
