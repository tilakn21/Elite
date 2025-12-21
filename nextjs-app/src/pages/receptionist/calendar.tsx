/**
 * Receptionist Calendar
 * View scheduled jobs and appointments
 */

import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { SectionCard } from '@/components/dashboard';
import { Button } from '@/components/ui';
import { receptionistService } from '@/services/receptionist.service';
import type { JobRequest, Salesperson } from '@/types/receptionist';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/calendar.styles';

// Icons
function ChevronLeft() {
    return <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 18l-6-6 6-6" /></svg>;
}

function ChevronRight() {
    return <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6" /></svg>;
}

const ReceptionistCalendarPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const [jobs, setJobs] = useState<JobRequest[]>([]);
    const [salespersons, setSalespersons] = useState<Salesperson[]>([]);

    // State for the currently selected particular date (for timeline)
    const [selectedDate, setSelectedDate] = useState(new Date());

    // State for the currently viewed month (for grid)
    const [viewDate, setViewDate] = useState(new Date());

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const [jobsData, salesData] = await Promise.all([
                receptionistService.getJobRequests(),
                receptionistService.getSalespersons(),
            ]);
            setJobs(jobsData);
            setSalespersons(salesData);
        } catch (error) {
            console.error('Failed to load data:', error);
        }
    };

    // Helper to get salesperson name
    const getSalespersonName = (id?: string) => {
        if (!id) return 'Unassigned';
        const sp = salespersons.find(s => s.id === id);
        return sp ? sp.name : id;
    };

    // Strict Filter: ONLY show jobs based on "Date of Appointment" as requested
    const getJobsForDate = (date: Date) => {
        // Use local date string (YYYY-MM-DD) to match how forms save it
        const dateStr = date.toLocaleDateString('en-CA');
        return jobs.filter(job => {
            // @ts-ignore - TypeScript strict null check workaround
            return job.dateOfAppointment ? (job.dateOfAppointment as string).startsWith(dateStr) : false;
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
                <title>Calendar | Receptionist</title>
            </Head>

            <div css={styles.container(theme)}>
                <div css={styles.header}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                        <div>
                            <h1 style={{ fontSize: '24px', fontWeight: 'bold', margin: 0 }}>Calendar</h1>
                            <p style={{ fontSize: '14px', color: '#6b7280', margin: '4px 0 0 0' }}>Job Creation Calendar</p>
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
                        <Button
                            variant="outline"
                            onClick={goToToday}
                        >
                            Today
                        </Button>
                    </div>
                </div>

                <div css={styles.calendarGrid}>
                    <SectionCard title={currentMonthLabel} iconColor="#6366f1">
                        <div css={styles.monthGrid}>
                            {weekDays.map(day => (
                                <div key={day} css={styles.weekDay}>{day}</div>
                            ))}
                            {calendarDays.map((date, i) => {
                                if (!date) return <div key={`empty-${i}`} />;

                                const dateStr = date.toDateString();
                                const isToday = dateStr === new Date().toDateString();
                                const isSelected = dateStr === selectedDate.toDateString();

                                // Check for dots based on APPOINTMENT date
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
                    </SectionCard>

                    <div css={styles.scheduleList}>
                        <h3 className="date-header">
                            {selectedDate.toLocaleDateString('en-GB', {
                                weekday: 'long',
                                day: 'numeric',
                                month: 'long'
                            })}
                        </h3>

                        {selectedDateJobs.length === 0 ? (
                            <p className="empty-message">No appointments scheduled for this day.</p>
                        ) : (
                            <div className="timeline">
                                {selectedDateJobs.map(job => (
                                    <div key={job.id} css={styles.timelineItem}>
                                        <div className="time">
                                            {job.timeOfVisit || 'All Day'}
                                        </div>
                                        <div className="content">
                                            <h4>{job.customerName}</h4>
                                            <p style={{ fontWeight: 500, color: '#4b5563' }}>{job.shopName}</p>

                                            {/* Extra details as requested */}
                                            <div style={{ fontSize: '13px', color: '#6b7280', marginTop: '8px', display: 'flex', flexDirection: 'column', gap: '4px' }}>
                                                {job.dateOfVisit && (
                                                    <span>Visit Date: {new Date(job.dateOfVisit).toLocaleDateString('en-GB')}</span>
                                                )}
                                                <span>Assigned to: <strong>{getSalespersonName(job.assignedSalesperson)}</strong></span>
                                            </div>

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

ReceptionistCalendarPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default ReceptionistCalendarPage;
