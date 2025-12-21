/**
 * Admin Calendar Page Styles
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
`;

export const controls = css`
    display: flex;
    gap: 12px;
`;

export const calendarGrid = css`
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 24px;

    @media (max-width: 1024px) {
        grid-template-columns: 1fr;
    }
`;

export const monthGrid = css`
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 8px;
    padding: 16px;
`;

export const weekDay = css`
    text-align: center;
    font-size: 12px;
    font-weight: 600;
    color: #6b7280;
    padding: 8px 0;
`;

export const dayCell = (isToday: boolean, isSelected: boolean) => css`
    aspect-ratio: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: relative;
    border-radius: 8px;
    cursor: pointer;
    background-color: ${isSelected ? '#3b82f6' : isToday ? '#eff6ff' : 'transparent'};
    color: ${isSelected ? '#fff' : isToday ? '#3b82f6' : '#1f2937'};
    border: ${isToday && !isSelected ? '2px solid #3b82f6' : '1px solid transparent'};

    &:hover {
        background-color: ${isSelected ? '#2563eb' : '#f3f4f6'};
    }

    .date-number {
        font-size: 14px;
        font-weight: ${isToday || isSelected ? '600' : '400'};
    }
`;

export const eventDot = css`
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background-color: #10b981;
    position: absolute;
    bottom: 4px;
`;

export const scheduleList = css`
    display: flex;
    flex-direction: column;
    gap: 16px;

    .date-header {
        font-size: 18px;
        font-weight: 600;
        color: #1f2937;
        margin-bottom: 12px;
    }

    .empty-message {
        color: #6b7280;
        font-size: 14px;
        padding: 24px;
        text-align: center;
        background: #f9fafb;
        border-radius: 8px;
    }

    .timeline {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
`;

export const timelineItem = css`
    display: flex;
    gap: 16px;
    padding: 16px;
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    transition: all 0.2s;

    &:hover {
        border-color: #3b82f6;
        box-shadow: 0 2px 8px rgba(59, 130, 246, 0.1);
    }

    .time {
        flex-shrink: 0;
        width: 80px;
        font-size: 14px;
        font-weight: 600;
        color: #6b7280;
    }

    .content {
        flex: 1;

        h4 {
            font-size: 16px;
            font-weight: 600;
            color: #1f2937;
            margin: 0 0 4px 0;
        }

        p {
            font-size: 14px;
            color: #6b7280;
            margin: 0 0 8px 0;
        }

        .status {
            display: inline-block;
            padding: 4px 12px;
            background: #eff6ff;
            color: #3b82f6;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            text-transform: capitalize;
        }
    }
`;

export const eventList = css`
    display: flex;
    flex-direction: column;
    gap: 12px;
`;

export const eventCard = css`
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    &:hover {
        border-color: #d1d5db;
    }
`;

export const dateHeader = css`
    font-size: 14px;
    font-weight: 600;
    color: #6b7280;
    margin-top: 16px;
    margin-bottom: 8px;
`;
