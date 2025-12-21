/**
 * Designer Calendar
 * View scheduled jobs and deadlines
 */

import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { designService } from '@/services';
import type { DesignJob } from '@/types/design';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/calendar.styles';

// Icons
function ChevronLeft() {
    return <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 18l-6-6 6-6" /></svg>;
}

function ChevronRight() {
    return <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg>;
}

const DesignCalendarPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const [jobs, setJobs] = useState<DesignJob[]>([]);

    // State for the currently selected particular date (for timeline)
    const [selectedDate, setSelectedDate] = useState(new Date());

    // State for the currently viewed month (for grid)
    const [viewDate, setViewDate] = useState(new Date());

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const jobsData = await designService.getDesignJobs();
            setJobs(jobsData);
        } catch (error) {
            console.error('Failed to load data:', error);
        }
    };

    // Filter jobs based on "Assigned Date" for now
    const getJobsForDate = (date: Date) => {
        const dateStr = date.toLocaleDateString('en-CA');
        return jobs.filter(job => job.assignedDate.startsWith(dateStr));
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
        const days = [];

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
                <title>Calendar | Design</title>
            </Head>

            <div css={styles.container(theme)}>
                <div css={styles.header}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                        <div>
                            <h1 style={{ fontSize: '24px', fontWeight: 'bold', margin: 0 }}>Calendar</h1>
                            <p style={{ fontSize: '14px', color: '#6b7280', margin: '4px 0 0 0' }}>Job Deadlines & Assignments</p>
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
                            <p className="empty-message">No jobs assigned for this day.</p>
                        ) : (
                            <div className="timeline">
                                {selectedDateJobs.map(job => (
                                    <div key={job.id} css={styles.timelineItem}>
                                        <div className="time">
                                            {job.priority ? job.priority.toUpperCase() : 'NORMAL'}
                                        </div>
                                        <div className="content">
                                            <h4>{job.customerName}</h4>
                                            <p style={{ fontWeight: 500, color: '#4b5563' }}>{job.shopName}</p>

                                            <div style={{ marginTop: '8px' }}>
                                                <span className="status">{job.status}</span>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </>
    );
};

DesignCalendarPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default DesignCalendarPage;
