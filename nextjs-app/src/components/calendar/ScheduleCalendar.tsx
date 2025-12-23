/**
 * ScheduleCalendar Component
 * Hybrid calendar with mini month picker and agenda/schedule view
 */

import { useState, useMemo } from 'react';
import { css } from '@emotion/react';
import { FaChevronLeft, FaChevronRight, FaCircle } from 'react-icons/fa';
import type { CalendarEvent } from '@/types';
import { getCurrentDepartment, getStatusColor } from '@/utils/status-utils';

interface ScheduleCalendarProps {
    events: CalendarEvent[];
    onEventClick: (event: CalendarEvent) => void;
    loading?: boolean;
}

const DAYS_OF_WEEK = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const MONTH_NAMES = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
];

const containerStyles = css`
    display: grid;
    grid-template-columns: 320px 1fr;
    gap: 24px;
    min-height: 600px;
    
    @media (max-width: 1024px) {
        grid-template-columns: 1fr;
    }
`;

const leftPanelStyles = css`
    background: white;
    border-radius: 20px;
    padding: 24px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    height: fit-content;
`;

const rightPanelStyles = css`
    background: white;
    border-radius: 20px;
    padding: 24px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
`;

const monthHeaderStyles = css`
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
`;

const monthTitleStyles = css`
    font-size: 18px;
    font-weight: 700;
    color: #1e293b;
`;

const navButtonStyles = css`
    width: 32px;
    height: 32px;
    border: none;
    border-radius: 8px;
    background: #f1f5f9;
    color: #64748b;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    
    &:hover {
        background: #3b82f6;
        color: white;
    }
`;

const miniGridStyles = css`
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 4px;
`;

const dayLabelStyles = css`
    text-align: center;
    font-size: 11px;
    font-weight: 600;
    color: #94a3b8;
    padding: 8px 0;
`;

const miniDayCellStyles = (isToday: boolean, isSelected: boolean, hasEvents: boolean, isCurrentMonth: boolean) => css`
    aspect-ratio: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: ${isToday || isSelected ? '600' : '500'};
    border-radius: 8px;
    cursor: ${isCurrentMonth ? 'pointer' : 'default'};
    transition: all 0.15s;
    position: relative;
    color: ${isSelected ? 'white' : isCurrentMonth ? '#1e293b' : '#cbd5e1'};
    background: ${isSelected ? '#3b82f6' : isToday ? '#eff6ff' : 'transparent'};
    
    ${isCurrentMonth && !isSelected && `
        &:hover {
            background: #f1f5f9;
        }
    `}
    
    ${hasEvents && !isSelected && `
        &::after {
            content: '';
            position: absolute;
            bottom: 4px;
            width: 4px;
            height: 4px;
            border-radius: 50%;
            background: #3b82f6;
        }
    `}
`;

const agendaHeaderStyles = css`
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
    padding-bottom: 16px;
    border-bottom: 1px solid #f1f5f9;
`;

const agendaDateStyles = css`
    h2 {
        font-size: 22px;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 4px;
    }
    
    p {
        font-size: 14px;
        color: #64748b;
    }
`;

const todayButtonStyles = css`
    padding: 10px 20px;
    font-size: 13px;
    font-weight: 600;
    border: none;
    border-radius: 10px;
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    color: white;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
    }
`;

const eventListStyles = css`
    display: flex;
    flex-direction: column;
    gap: 12px;
    max-height: 500px;
    overflow-y: auto;
    padding-right: 4px;
    
    &::-webkit-scrollbar {
        width: 6px;
    }
    &::-webkit-scrollbar-track {
        background: #f1f5f9;
        border-radius: 3px;
    }
    &::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 3px;
    }
`;

const eventCardStyles = (statusColor: string) => css`
    display: flex;
    align-items: stretch;
    background: white;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    overflow: hidden;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
        transform: translateX(4px);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
        border-color: ${statusColor};
    }
`;

const eventColorBarStyles = (color: string) => css`
    width: 4px;
    background: ${color};
    flex-shrink: 0;
`;

const eventContentStyles = css`
    flex: 1;
    padding: 16px;
`;

const eventTitleStyles = css`
    font-size: 15px;
    font-weight: 600;
    color: #1e293b;
    margin-bottom: 6px;
`;

const eventMetaStyles = css`
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    font-size: 13px;
    color: #64748b;
    
    .tag {
        display: inline-flex;
        align-items: center;
        gap: 4px;
    }
`;

const statusBadgeStyles = (color: string) => css`
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 10px;
    background: ${color}15;
    color: ${color};
    border-radius: 6px;
    font-size: 12px;
    font-weight: 500;
`;

const emptyStateStyles = css`
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 48px;
    color: #94a3b8;
    text-align: center;
    
    .icon {
        font-size: 48px;
        margin-bottom: 16px;
        opacity: 0.5;
    }
    
    h3 {
        font-size: 18px;
        font-weight: 600;
        color: #64748b;
        margin-bottom: 8px;
    }
    
    p {
        font-size: 14px;
    }
`;

const loadingStyles = css`
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 400px;
    color: #64748b;
`;

const legendStyles = css`
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    margin-top: 20px;
    padding-top: 16px;
    border-top: 1px solid #f1f5f9;
`;

const legendItemStyles = (color: string) => css`
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 11px;
    color: #64748b;
    
    .dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: ${color};
    }
`;

export function ScheduleCalendar({ events, onEventClick, loading }: ScheduleCalendarProps) {
    const today = new Date();

    const [currentMonth, setCurrentMonth] = useState(today.getMonth());
    const [currentYear, setCurrentYear] = useState(today.getFullYear());
    const [selectedDate, setSelectedDate] = useState<string>(formatDateKey(today));

    function formatDateKey(date: Date): string {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

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

    // Selected date events
    const selectedEvents = useMemo(() => {
        return eventsByDate[selectedDate] || [];
    }, [eventsByDate, selectedDate]);

    // Calendar grid days
    const calendarDays = useMemo(() => {
        const firstDay = new Date(currentYear, currentMonth, 1);
        const lastDay = new Date(currentYear, currentMonth + 1, 0);
        const startDay = firstDay.getDay();
        const daysInMonth = lastDay.getDate();

        const days: Array<{ date: Date; isCurrentMonth: boolean }> = [];

        // Previous month
        const prevMonthLastDay = new Date(currentYear, currentMonth, 0).getDate();
        for (let i = startDay - 1; i >= 0; i--) {
            days.push({
                date: new Date(currentYear, currentMonth - 1, prevMonthLastDay - i),
                isCurrentMonth: false,
            });
        }

        // Current month
        for (let i = 1; i <= daysInMonth; i++) {
            days.push({
                date: new Date(currentYear, currentMonth, i),
                isCurrentMonth: true,
            });
        }

        // Next month (fill to 42)
        const remaining = 42 - days.length;
        for (let i = 1; i <= remaining; i++) {
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
        const todayKey = formatDateKey(today);
        setCurrentMonth(today.getMonth());
        setCurrentYear(today.getFullYear());
        setSelectedDate(todayKey);
    };

    const isToday = (date: Date) => formatDateKey(date) === formatDateKey(today);

    const formatSelectedDate = (dateStr: string) => {
        const date = new Date(dateStr);
        return date.toLocaleDateString('en-GB', {
            weekday: 'long',
            day: 'numeric',
            month: 'long',
            year: 'numeric'
        });
    };

    if (loading) {
        return (
            <div css={containerStyles}>
                <div css={leftPanelStyles}>
                    <div css={loadingStyles}>Loading...</div>
                </div>
                <div css={rightPanelStyles}>
                    <div css={loadingStyles}>Loading events...</div>
                </div>
            </div>
        );
    }

    return (
        <div css={containerStyles}>
            {/* Left Panel - Mini Calendar */}
            <div css={leftPanelStyles}>
                <div css={monthHeaderStyles}>
                    <button css={navButtonStyles} onClick={() => navigateMonth(-1)}>
                        <FaChevronLeft size={12} />
                    </button>
                    <span css={monthTitleStyles}>
                        {MONTH_NAMES[currentMonth]} {currentYear}
                    </span>
                    <button css={navButtonStyles} onClick={() => navigateMonth(1)}>
                        <FaChevronRight size={12} />
                    </button>
                </div>

                <div css={miniGridStyles}>
                    {DAYS_OF_WEEK.map((day, i) => (
                        <div key={i} css={dayLabelStyles}>{day}</div>
                    ))}

                    {calendarDays.map(({ date, isCurrentMonth }, index) => {
                        const dateKey = formatDateKey(date);
                        const hasEvents = (eventsByDate[dateKey]?.length ?? 0) > 0;
                        const isTodayCell = isToday(date);
                        const isSelected = selectedDate === dateKey;

                        return (
                            <div
                                key={index}
                                css={miniDayCellStyles(isTodayCell, isSelected, hasEvents, isCurrentMonth)}
                                onClick={() => isCurrentMonth && setSelectedDate(dateKey)}
                            >
                                {date.getDate()}
                            </div>
                        );
                    })}
                </div>

                {/* Legend */}
                <div css={legendStyles}>
                    <div css={legendItemStyles('#ec4899')}>
                        <span className="dot" />Reception
                    </div>
                    <div css={legendItemStyles('#f59e0b')}>
                        <span className="dot" />Sales
                    </div>
                    <div css={legendItemStyles('#8b5cf6')}>
                        <span className="dot" />Design
                    </div>
                    <div css={legendItemStyles('#6366f1')}>
                        <span className="dot" />Production
                    </div>
                    <div css={legendItemStyles('#0ea5e9')}>
                        <span className="dot" />Printing
                    </div>
                </div>
            </div>

            {/* Right Panel - Agenda */}
            <div css={rightPanelStyles}>
                <div css={agendaHeaderStyles}>
                    <div css={agendaDateStyles}>
                        <h2>{formatSelectedDate(selectedDate)}</h2>
                        <p>{selectedEvents.length} job{selectedEvents.length !== 1 ? 's' : ''} scheduled</p>
                    </div>
                    <button css={todayButtonStyles} onClick={goToToday}>
                        Today
                    </button>
                </div>

                {selectedEvents.length === 0 ? (
                    <div css={emptyStateStyles}>
                        <div className="icon">📅</div>
                        <h3>No Jobs Scheduled</h3>
                        <p>There are no jobs for this date.<br />Select another date to view scheduled jobs.</p>
                    </div>
                ) : (
                    <div css={eventListStyles}>
                        {selectedEvents.map(event => {
                            const statusColor = getStatusColor(event.status);
                            const department = getCurrentDepartment(event.status);
                            const metadata = event.metadata as { client?: string; shopName?: string; jobCode?: string } | undefined;

                            return (
                                <div
                                    key={event.id}
                                    css={eventCardStyles(statusColor)}
                                    onClick={() => onEventClick(event)}
                                >
                                    <div css={eventColorBarStyles(statusColor)} />
                                    <div css={eventContentStyles}>
                                        <div css={eventTitleStyles}>{event.title}</div>
                                        <div css={eventMetaStyles}>
                                            <span className="tag">
                                                {metadata?.client || 'Unknown Client'}
                                            </span>
                                            {metadata?.shopName && (
                                                <span className="tag">
                                                    🏪 {metadata.shopName}
                                                </span>
                                            )}
                                        </div>
                                        <div style={{ marginTop: '10px' }}>
                                            <span css={statusBadgeStyles(statusColor)}>
                                                <FaCircle size={6} />
                                                {department}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}
            </div>
        </div>
    );
}

export default ScheduleCalendar;
