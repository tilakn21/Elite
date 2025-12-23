/**
 * CalendarGrid Component
 * Monthly grid calendar with job indicators and date selection
 */

import { useState, useMemo } from 'react';
import { css, useTheme, Theme } from '@emotion/react';
import { FaChevronLeft, FaChevronRight } from 'react-icons/fa';
import type { CalendarEvent } from '@/types';

interface CalendarGridProps {
    events: CalendarEvent[];
    onDateSelect: (date: string, events: CalendarEvent[]) => void;
    loading?: boolean;
}

const DAYS_OF_WEEK = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTH_NAMES = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
];

const containerStyles = (theme: Theme) => css`
    background: ${theme.colors.card};
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
`;

const headerStyles = css`
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
`;

const monthTitleStyles = (theme: Theme) => css`
    font-size: 22px;
    font-weight: 700;
    color: ${theme.colors.textPrimary};
`;

const navButtonStyles = (theme: Theme) => css`
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border: none;
    border-radius: 10px;
    background: ${theme.colors.background};
    color: ${theme.colors.textSecondary};
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
        background: ${theme.colors.accent};
        color: white;
        transform: scale(1.05);
    }
`;

const navContainerStyles = css`
    display: flex;
    gap: 8px;
    align-items: center;
`;

const gridStyles = css`
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 8px;
`;

const dayHeaderStyles = (theme: Theme) => css`
    text-align: center;
    padding: 12px 0;
    font-size: 13px;
    font-weight: 600;
    color: ${theme.colors.textSecondary};
    text-transform: uppercase;
    letter-spacing: 0.5px;
`;

const dayCellStyles = (theme: Theme, isToday: boolean, isSelected: boolean, hasEvents: boolean, isCurrentMonth: boolean) => css`
    min-height: 80px;
    padding: 8px;
    display: flex;
    flex-direction: column;
    align-items: center;
    border-radius: 12px;
    cursor: ${hasEvents ? 'pointer' : 'default'};
    transition: all 0.2s;
    position: relative;
    background: ${isSelected ? theme.colors.accent : isToday ? `${theme.colors.accent}10` : theme.colors.background};
    border: 2px solid ${isToday && !isSelected ? theme.colors.accent : 'transparent'};
    opacity: ${isCurrentMonth ? 1 : 0.4};
    
    ${hasEvents && !isSelected && isCurrentMonth && `
        &:hover {
            background: ${theme.colors.accent}15;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
    `}
`;

const dayNumberStyles = (isSelected: boolean) => css`
    font-size: 16px;
    font-weight: 600;
    color: ${isSelected ? 'white' : 'inherit'};
    margin-bottom: 4px;
`;

const eventIndicatorContainer = css`
    display: flex;
    flex-wrap: wrap;
    gap: 3px;
    justify-content: center;
    margin-top: 4px;
`;

const eventDotStyles = css`
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: linear-gradient(135deg, #4ECDC4, #2563eb);
`;

const eventCountStyles = (isSelected: boolean) => css`
    font-size: 11px;
    font-weight: 600;
    color: ${isSelected ? 'rgba(255,255,255,0.9)' : '#4ECDC4'};
    margin-top: 4px;
    padding: 2px 8px;
    background: ${isSelected ? 'rgba(255,255,255,0.2)' : 'rgba(78, 205, 196, 0.15)'};
    border-radius: 10px;
`;

const todayButtonStyles = (theme: Theme) => css`
    padding: 8px 16px;
    font-size: 13px;
    font-weight: 600;
    border: none;
    border-radius: 8px;
    background: ${theme.colors.accent}15;
    color: ${theme.colors.accent};
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
        background: ${theme.colors.accent};
        color: white;
    }
`;

const loadingStyles = css`
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 400px;
    color: #6b7280;
    font-size: 15px;
`;

export function CalendarGrid({ events, onDateSelect, loading }: CalendarGridProps) {
    const theme = useTheme();
    const today = new Date();

    const [currentMonth, setCurrentMonth] = useState(today.getMonth());
    const [currentYear, setCurrentYear] = useState(today.getFullYear());
    const [selectedDate, setSelectedDate] = useState<string | null>(null);

    // Group events by date
    const eventsByDate = useMemo(() => {
        const grouped: Record<string, CalendarEvent[]> = {};
        events.forEach(event => {
            const date = event.date;
            if (date) {
                if (!grouped[date]) {
                    grouped[date] = [];
                }
                grouped[date].push(event);
            }
        });
        return grouped;
    }, [events]);

    // Calculate calendar grid days
    const calendarDays = useMemo(() => {
        const firstDay = new Date(currentYear, currentMonth, 1);
        const lastDay = new Date(currentYear, currentMonth + 1, 0);
        const startDay = firstDay.getDay();
        const daysInMonth = lastDay.getDate();

        const days: Array<{ date: Date; isCurrentMonth: boolean }> = [];

        // Previous month days
        const prevMonthLastDay = new Date(currentYear, currentMonth, 0).getDate();
        for (let i = startDay - 1; i >= 0; i--) {
            days.push({
                date: new Date(currentYear, currentMonth - 1, prevMonthLastDay - i),
                isCurrentMonth: false,
            });
        }

        // Current month days
        for (let i = 1; i <= daysInMonth; i++) {
            days.push({
                date: new Date(currentYear, currentMonth, i),
                isCurrentMonth: true,
            });
        }

        // Next month days (to fill grid to 6 rows)
        const remainingDays = 42 - days.length;
        for (let i = 1; i <= remainingDays; i++) {
            days.push({
                date: new Date(currentYear, currentMonth + 1, i),
                isCurrentMonth: false,
            });
        }

        return days;
    }, [currentMonth, currentYear]);

    const navigateMonth = (direction: number) => {
        const newDate = new Date(currentYear, currentMonth + direction, 1);
        setCurrentMonth(newDate.getMonth());
        setCurrentYear(newDate.getFullYear());
    };

    const goToToday = () => {
        setCurrentMonth(today.getMonth());
        setCurrentYear(today.getFullYear());
    };

    const handleDateClick = (dateStr: string, dayEvents: CalendarEvent[]) => {
        setSelectedDate(dateStr);
        onDateSelect(dateStr, dayEvents);
    };

    const formatDateKey = (date: Date): string => {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    const isToday = (date: Date) => {
        return formatDateKey(date) === formatDateKey(today);
    };

    if (loading) {
        return (
            <div css={containerStyles(theme)}>
                <div css={loadingStyles}>
                    Loading calendar...
                </div>
            </div>
        );
    }

    return (
        <div css={containerStyles(theme)}>
            {/* Header */}
            <div css={headerStyles}>
                <h2 css={monthTitleStyles(theme)}>
                    {MONTH_NAMES[currentMonth]} {currentYear}
                </h2>
                <div css={navContainerStyles}>
                    <button css={todayButtonStyles(theme)} onClick={goToToday}>
                        Today
                    </button>
                    <button css={navButtonStyles(theme)} onClick={() => navigateMonth(-1)}>
                        <FaChevronLeft size={14} />
                    </button>
                    <button css={navButtonStyles(theme)} onClick={() => navigateMonth(1)}>
                        <FaChevronRight size={14} />
                    </button>
                </div>
            </div>

            {/* Calendar Grid */}
            <div css={gridStyles}>
                {/* Day headers */}
                {DAYS_OF_WEEK.map(day => (
                    <div key={day} css={dayHeaderStyles(theme)}>
                        {day}
                    </div>
                ))}

                {/* Day cells */}
                {calendarDays.map(({ date, isCurrentMonth }, index) => {
                    const dateKey = formatDateKey(date);
                    const dayEvents = eventsByDate[dateKey] || [];
                    const hasEvents = dayEvents.length > 0;
                    const isTodayCell = isToday(date);
                    const isSelected = selectedDate === dateKey;

                    return (
                        <div
                            key={index}
                            css={dayCellStyles(theme, isTodayCell, isSelected, hasEvents, isCurrentMonth)}
                            onClick={() => hasEvents && isCurrentMonth && handleDateClick(dateKey, dayEvents)}
                        >
                            <span css={dayNumberStyles(isSelected)}>
                                {date.getDate()}
                            </span>

                            {hasEvents && isCurrentMonth && (
                                <>
                                    <div css={eventIndicatorContainer}>
                                        {dayEvents.slice(0, 4).map((_, i: number) => (
                                            <span key={i} css={eventDotStyles} />
                                        ))}
                                    </div>
                                    <span css={eventCountStyles(isSelected)}>
                                        {dayEvents.length} job{dayEvents.length > 1 ? 's' : ''}
                                    </span>
                                </>
                            )}
                        </div>
                    );
                })}
            </div>
        </div>
    );
}

export default CalendarGrid;
