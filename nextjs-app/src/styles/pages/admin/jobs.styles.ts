/**
 * Admin Jobs Page Styles
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

export const filters = css`
    display: flex;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
`;

export const pagination = css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 16px;
`;
