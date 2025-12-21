/**
 * Salesperson Calendar Screen Styles
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

export const calendarCard = css`
    background: white;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
    
    @media (max-width: 768px) {
        padding: 12px;
        border-radius: 12px;
    }
`;

export const calendarHeader = css`
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
    
    @media (max-width: 768px) {
        margin-bottom: 16px;
    }
`;

export const monthTitle = css`
    font-size: 20px;
    font-weight: 700;
    color: #1B2330;
    
    @media (max-width: 768px) {
        font-size: 16px;
    }
`;

export const navButtons = css`
    display: flex;
    gap: 8px;
`;

export const navButton = css`
    width: 36px;
    height: 36px;
    border: 1px solid #E5E7EB;
    border-radius: 8px;
    background: white;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #666;
    transition: all 0.2s;
    
    &:hover {
        background: #F5F5F5;
        border-color: #BDBDBD;
    }
`;

export const weekdaysRow = css`
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 4px;
    margin-bottom: 8px;
    
    @media (max-width: 768px) {
        gap: 2px;
        margin-bottom: 4px;
    }
`;

export const weekdayLabel = css`
    text-align: center;
    font-size: 12px;
    font-weight: 600;
    color: #9CA3AF;
    padding: 8px 0;
    
    @media (max-width: 768px) {
        font-size: 10px;
        padding: 4px 0;
    }
`;

export const daysGrid = css`
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 4px;
    
    @media (max-width: 768px) {
        gap: 2px;
    }
`;

export const dayCell = (isToday: boolean, isCurrentMonth: boolean, hasPending: boolean, hasCompleted: boolean) => css`
    aspect-ratio: 1;
    min-height: 60px;
    border: 1px solid ${isToday ? '#5A6CEA' : hasPending ? '#EF4444' : hasCompleted ? '#10B981' : '#E5E7EB'};
    border-radius: 8px;
    padding: 6px;
    display: flex;
    flex-direction: column;
    cursor: ${(hasPending || hasCompleted) ? 'pointer' : 'default'};
    background: ${!isCurrentMonth ? 'white' :
        isToday ? '#EEF0FF' :
            hasPending ? '#FEE2E2' :
                hasCompleted ? '#D1FAE5' :
                    'white'
    };
    opacity: ${isCurrentMonth ? 1 : 0.4};
    transition: all 0.2s;
    position: relative;
    overflow: hidden;
    
    ${(hasPending || hasCompleted) && isCurrentMonth && `
        &:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 10;
        }
    `}
    
    @media (max-width: 768px) {
        min-height: 40px;
        padding: 3px;
        border-radius: 4px;
        border-width: ${hasPending || hasCompleted ? '2px' : '1px'};
    }
    
    @media (max-width: 480px) {
        min-height: 35px;
        padding: 2px;
    }
`;

export const dayNumber = (isToday: boolean) => css`
    font-size: 14px;
    font-weight: ${isToday ? 700 : 500};
    color: ${isToday ? '#5A6CEA' : '#1B2330'};
    line-height: 1;
    
    @media (max-width: 768px) {
        font-size: 11px;
    }
    
    @media (max-width: 480px) {
        font-size: 10px;
    }
`;

export const eventsSection = css`
    margin-top: 24px;
`;

export const eventsSectionTitle = css`
    font-size: 16px;
    font-weight: 600;
    color: #1B2330;
    margin-bottom: 12px;
`;

export const eventsList = css`
    display: flex;
    flex-direction: column;
    gap: 8px;
`;

export const eventItem = (isPending: boolean) => css`
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: ${isPending ? '#FEE2E2' : '#D1FAE5'};
    border-radius: 8px;
    
    .dot {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: ${isPending ? '#EF4444' : '#10B981'};
    }
    
    .info {
        flex: 1;
        
        .customer {
            font-weight: 600;
            color: #1B2330;
            font-size: 14px;
        }
        
        .job-code {
            font-size: 12px;
            color: #666;
        }
    }
    
    .status {
        font-size: 12px;
        font-weight: 600;
        color: ${isPending ? '#EF4444' : '#10B981'};
    }
`;

export const loadingContainer = css`
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 200px;
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

export const legend = css`
    display: flex;
    gap: 16px;
    margin-bottom: 16px;
    font-size: 13px;
    color: #666;
    flex-wrap: wrap;
    
    span {
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    @media (max-width: 768px) {
        font-size: 11px;
        gap: 12px;
    }
`;

export const legendSwatch = (color: string, border: string) => css`
    width: 20px;
    height: 20px;
    border-radius: 4px;
    background: ${color};
    border: 2px solid ${border};
    
    @media (max-width: 768px) {
        width: 16px;
        height: 16px;
    }
`;
