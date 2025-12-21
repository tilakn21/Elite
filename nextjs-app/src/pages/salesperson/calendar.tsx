/**
 * Salesperson Calendar Screen
 * Shows calendar with scheduled job visits
 */

import { useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { useAuth } from '@/state';
import { salespersonService } from '@/services/salesperson.service';
import type { SiteVisitItem } from '@/types/salesperson';
import * as styles from '@/styles/pages/salesperson/calendar.styles';

const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'];

export default function CalendarPage() {
    const theme = useTheme();
    const { state: authState } = useAuth();

    const [currentDate, setCurrentDate] = useState(new Date());
    const [selectedDate, setSelectedDate] = useState<Date | null>(null);
    const [jobs, setJobs] = useState<SiteVisitItem[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    const salespersonId = authState.user?.employeeId;

    // Fetch jobs
    useEffect(() => {
        async function fetchJobs() {
            if (!salespersonId) {
                setIsLoading(false);
                return;
            }

            setIsLoading(true);
            try {
                const assignedJobs = await salespersonService.getAssignedJobs(salespersonId);
                setJobs(assignedJobs);
            } catch (error) {
                console.error('Failed to fetch jobs:', error);
            } finally {
                setIsLoading(false);
            }
        }

        fetchJobs();
    }, [salespersonId]);

    // Get jobs by date
    const jobsByDate = useMemo((): Record<string, SiteVisitItem[]> => {
        const map: Record<string, SiteVisitItem[]> = {};
        jobs.forEach(job => {
            if (job.dateOfVisit) {
                const parts = job.dateOfVisit.split('T');
                const dateKey = parts[0] ?? '';
                if (dateKey) {
                    if (!map[dateKey]) map[dateKey] = [];
                    map[dateKey].push(job);
                }
            }
        });
        return map;
    }, [jobs]);

    // Generate calendar days
    const calendarDays = useMemo(() => {
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth();

        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const startPadding = firstDay.getDay();
        const totalDays = lastDay.getDate();

        const days: { date: Date; isCurrentMonth: boolean }[] = [];

        // Previous month days
        for (let i = startPadding - 1; i >= 0; i--) {
            const date = new Date(year, month, -i);
            days.push({ date, isCurrentMonth: false });
        }

        // Current month days
        for (let i = 1; i <= totalDays; i++) {
            const date = new Date(year, month, i);
            days.push({ date, isCurrentMonth: true });
        }

        // Next month days (fill to 42 = 6 rows)
        const remaining = 42 - days.length;
        for (let i = 1; i <= remaining; i++) {
            const date = new Date(year, month + 1, i);
            days.push({ date, isCurrentMonth: false });
        }

        return days;
    }, [currentDate]);

    // Navigation
    const goToPrevMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
    };

    const goToNextMonth = () => {
        setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
    };

    // Get selected day jobs
    const selectedDayJobs = useMemo((): SiteVisitItem[] => {
        if (!selectedDate) return [];
        const parts = selectedDate.toISOString().split('T');
        const dateKey = parts[0] ?? '';
        return jobsByDate[dateKey] || [];
    }, [selectedDate, jobsByDate]);

    // Check if date is today
    const isToday = (date: Date) => {
        const today = new Date();
        return date.toDateString() === today.toDateString();
    };

    // Format date key
    const formatDateKey = (date: Date): string => {
        const parts = date.toISOString().split('T');
        return parts[0] ?? '';
    };

    return (
        <>
            <Head>
                <title>Calendar | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {isLoading ? (
                        <div css={styles.loadingContainer}>
                            <div css={styles.spinnerAnimation} />
                        </div>
                    ) : (
                        <div css={styles.calendarCard}>
                            {/* Header */}
                            <div css={styles.calendarHeader}>
                                <h2 css={styles.monthTitle}>
                                    {MONTHS[currentDate.getMonth()]} {currentDate.getFullYear()}
                                </h2>
                                <div css={styles.navButtons}>
                                    <button css={styles.navButton} onClick={goToPrevMonth}>
                                        ←
                                    </button>
                                    <button css={styles.navButton} onClick={goToNextMonth}>
                                        →
                                    </button>
                                </div>
                            </div>

                            {/* Legend */}
                            <div css={styles.legend}>
                                <span><div css={styles.legendSwatch('#FEE2E2', '#EF4444')} /> Pending</span>
                                <span><div css={styles.legendSwatch('#D1FAE5', '#10B981')} /> Completed</span>
                            </div>

                            {/* Weekdays */}
                            <div css={styles.weekdaysRow}>
                                {WEEKDAYS.map(day => (
                                    <div key={day} css={styles.weekdayLabel}>{day}</div>
                                ))}
                            </div>

                            {/* Days */}
                            <div css={styles.daysGrid}>
                                {calendarDays.map(({ date, isCurrentMonth }, index) => {
                                    const dateKey = formatDateKey(date);
                                    const dayJobs: SiteVisitItem[] = dateKey ? (jobsByDate[dateKey] || []) : [];
                                    const hasPending = dayJobs.some((j: SiteVisitItem) => j.status === 'pending');
                                    const hasCompleted = dayJobs.some((j: SiteVisitItem) => j.status !== 'pending');

                                    return (
                                        <div
                                            key={index}
                                            css={styles.dayCell(isToday(date), isCurrentMonth, hasPending, hasCompleted)}
                                            onClick={() => dayJobs.length > 0 && setSelectedDate(date)}
                                        >
                                            <span css={styles.dayNumber(isToday(date))}>
                                                {date.getDate()}
                                            </span>
                                            {(hasPending || hasCompleted) && isCurrentMonth && (
                                                <div style={{
                                                    marginTop: 'auto',
                                                    fontSize: '10px',
                                                    fontWeight: 600,
                                                    color: hasPending ? '#DC2626' : '#059669',
                                                    textAlign: 'center',
                                                    lineHeight: 1
                                                }}>
                                                    {dayJobs.length}
                                                </div>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>

                            {/* Selected day events */}
                            {selectedDate && selectedDayJobs.length > 0 && (
                                <div css={styles.eventsSection}>
                                    <h3 css={styles.eventsSectionTitle}>
                                        Jobs for {selectedDate.toLocaleDateString('en-GB', {
                                            weekday: 'long',
                                            day: 'numeric',
                                            month: 'long'
                                        })}
                                    </h3>
                                    <div css={styles.eventsList}>
                                        {selectedDayJobs.map((job: SiteVisitItem) => (
                                            <div key={job.jobCode} css={styles.eventItem(job.status === 'pending')}>
                                                <div className="dot" />
                                                <div className="info">
                                                    <div className="customer">{job.customerName || 'Unknown Customer'}</div>
                                                    <div className="job-code">Job: {job.jobCode}</div>
                                                </div>
                                                <span className="status">
                                                    {job.status === 'pending' ? 'Pending' : 'Completed'}
                                                </span>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}
                        </div>
                    )}
                </div>
            </AppLayout>
        </>
    );
}
