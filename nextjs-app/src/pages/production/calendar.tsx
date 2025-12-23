/**
 * Production Calendar
 * View jobs based on production timeline dates
 */

import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { productionService } from '@/services';
import type { ProductionJob } from '@/types/production';
import type { NextPageWithLayout } from '@/pages/_app';
import * as styles from '@/styles/pages/admin/calendar.styles';

// Icons
function ChevronLeft() {
    return <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 18l-6-6 6-6" /></svg>;
}

function ChevronRight() {
    return <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg>;
}

// Status badge helper
const getStatusInfo = (status: string): { label: string; color: string; bgColor: string } => {
    const statusMap: Record<string, { label: string; color: string; bgColor: string }> = {
        pending: { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' },
        in_progress: { label: 'In Progress', color: '#1E40AF', bgColor: '#DBEAFE' },
        ready_for_printing: { label: 'Ready for Printing', color: '#065F46', bgColor: '#D1FAE5' },
    };
    return statusMap[status] || { label: 'Pending', color: '#92400E', bgColor: '#FEF3C7' };
};

const ProductionCalendarPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const router = useRouter();
    const [jobs, setJobs] = useState<ProductionJob[]>([]);

    // State for the currently selected date (for timeline)
    const [selectedDate, setSelectedDate] = useState(new Date());

    // State for the currently viewed month (for grid)
    const [viewDate, setViewDate] = useState(new Date());

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const jobsData = await productionService.getProductionJobs();
            setJobs(jobsData);
        } catch (error) {
            console.error('Failed to load data:', error);
        }
    };

    // Filter jobs based on production start date from timeline
    const getJobsForDate = (date: Date) => {
        const dateStr = date.toLocaleDateString('en-CA'); // YYYY-MM-DD format
        return jobs.filter(job => {
            // Use productionStartedAt if available
            const jobDate = job.productionStartedAt;
            return jobDate?.startsWith(dateStr);
        });
    };

    // Month Navigation
    const changeMonth = (increment: number) => {
        const newDate = new Date(viewDate);
        newDate.setMonth(newDate.getMonth() + increment);
        setViewDate(newDate);
    };

    const goToToday = () => {
        const now = new Date();
        setSelectedDate(now);
        setViewDate(now);
    };

    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const currentMonthLabel = viewDate.toLocaleString('default', { month: 'long', year: 'numeric' });

    // Generate calendar days for VIEW DATE
    const getDaysInMonth = (date: Date) => {
        const year = date.getFullYear();
        const month = date.getMonth();
        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const days: (Date | null)[] = [];

        // Add padding for previous month
        for (let i = 0; i < firstDay.getDay(); i++) {
            days.push(null);
        }

        // Add days
        for (let i = 1; i <= lastDay.getDate(); i++) {
            days.push(new Date(year, month, i));
        }

        return days;
    };

    const calendarDays = getDaysInMonth(viewDate);
    const selectedDateJobs = getJobsForDate(selectedDate);

    return (
        <>
            <Head>
                <title>Calendar | Production</title>
            </Head>

            <div css={styles.container(theme)}>
                <div css={styles.header}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                        <div>
                            <h1 style={{ fontSize: '24px', fontWeight: 'bold', margin: 0 }}>Production Calendar</h1>
                            <p style={{ fontSize: '14px', color: '#6b7280', margin: '4px 0 0 0' }}>Jobs by Production Start Date</p>
                        </div>
                        <div style={{ display: 'flex', gap: '8px', alignItems: 'center', marginLeft: '8px' }}>
                            <button onClick={() => changeMonth(-1)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4 }}>
                                <ChevronLeft />
                            </button>
                            <span style={{ fontSize: '16px', fontWeight: 600, minWidth: 140, textAlign: 'center' }}>
                                {currentMonthLabel}
                            </span>
                            <button onClick={() => changeMonth(1)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4 }}>
                                <ChevronRight />
                            </button>
                        </div>
                    </div>

                    <div css={styles.controls}>
                        <button
                            onClick={goToToday}
                            style={{
                                padding: '8px 16px',
                                borderRadius: '8px',
                                border: '1px solid #E5E7EB',
                                background: 'white',
                                cursor: 'pointer',
                                fontWeight: 500
                            }}
                        >
                            Today
                        </button>
                    </div>
                </div>

                <div css={styles.calendarGrid}>
                    <div className="section-card" style={{ background: 'white', borderRadius: '12px', padding: '20px', boxShadow: '0 2px 8px rgba(0,0,0,0.05)' }}>
                        <div css={styles.monthGrid}>
                            {weekDays.map(day => (
                                <div key={day} css={styles.weekDay}>{day}</div>
                            ))}
                            {calendarDays.map((date, i) => {
                                if (!date) return <div key={`empty-${i}`} />;

                                const dateStr = date.toDateString();
                                const isToday = dateStr === new Date().toDateString();
                                const isSelected = dateStr === selectedDate.toDateString();
                                const hasJobs = getJobsForDate(date).length > 0;

                                return (
                                    <div
                                        key={date.toISOString()}
                                        css={styles.dayCell(isToday, isSelected)}
                                        onClick={() => setSelectedDate(date)}
                                    >
                                        <span className="date-number">{date.getDate()}</span>
                                        {hasJobs && <div css={styles.eventDot} />}
                                    </div>
                                );
                            })}
                        </div>
                    </div>

                    <div css={styles.scheduleList}>
                        <h3 className="date-header">
                            {selectedDate.toLocaleDateString('en-GB', {
                                weekday: 'long',
                                day: 'numeric',
                                month: 'long'
                            })}
                        </h3>

                        {selectedDateJobs.length === 0 ? (
                            <p className="empty-message">No production jobs started on this day.</p>
                        ) : (
                            <div className="timeline">
                                {selectedDateJobs.map(job => {
                                    const statusInfo = getStatusInfo(job.status);
                                    return (
                                        <div
                                            key={job.id}
                                            css={styles.timelineItem}
                                            onClick={() => router.push(`/production/jobs/${job.id}`)}
                                            style={{ cursor: 'pointer' }}
                                        >
                                            <div className="time">
                                                {job.priority?.toUpperCase() || 'NORMAL'}
                                            </div>
                                            <div className="content">
                                                <h4>{job.customerName}</h4>
                                                <p style={{ fontWeight: 500, color: '#4b5563' }}>{job.shopName}</p>

                                                {job.progress > 0 && (
                                                    <div style={{ marginTop: '8px' }}>
                                                        <div style={{ height: '4px', background: '#E5E7EB', borderRadius: '2px', overflow: 'hidden' }}>
                                                            <div style={{ height: '100%', width: `${job.progress}%`, background: '#3B82F6', borderRadius: '2px' }} />
                                                        </div>
                                                        <span style={{ fontSize: '11px', color: '#6B7280' }}>{job.progress}% complete</span>
                                                    </div>
                                                )}

                                                <div style={{ marginTop: '8px' }}>
                                                    <span
                                                        className="status"
                                                        style={{
                                                            background: statusInfo.bgColor,
                                                            color: statusInfo.color,
                                                            padding: '2px 8px',
                                                            borderRadius: '12px',
                                                            fontSize: '11px',
                                                            fontWeight: 500,
                                                        }}
                                                    >
                                                        {statusInfo.label}
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
            </div>
        </>
    );
};

ProductionCalendarPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default ProductionCalendarPage;
