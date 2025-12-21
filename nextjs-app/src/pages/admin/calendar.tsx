import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { css, useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { SectionCard } from '@/components/dashboard';
import { Button, Modal, Badge } from '@/components/ui';
import { getCalendarEvents } from '@/services';
import type { CalendarEvent } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/calendar.styles';

/**
 * Admin Calendar Page
 * Displays scheduled jobs in a list view (Calendar UI to be enhanced)
 */

const AdminCalendarPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const [events, setEvents] = useState<CalendarEvent[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(null);

    useEffect(() => {
        loadEvents();
    }, []);

    const loadEvents = async () => {
        try {
            setLoading(true);
            const data = await getCalendarEvents(new Date());
            setEvents(data);
        } catch (error) {
            console.error('Failed to load events:', error);
        } finally {
            setLoading(false);
        }
    };

    // Group events by date
    const groupedEvents = events.reduce((groups, event) => {
        const date = event.date;
        if (!groups[date]) {
            groups[date] = [];
        }
        groups[date].push(event);
        return groups;
    }, {} as Record<string, CalendarEvent[]>);

    return (
        <>
            <Head>
                <title>Calendar | Elite Signboard</title>
            </Head>

            <div css={styles.container(theme)}>
                <h1 style={{ fontSize: '24px', fontWeight: 'bold' }}>Calendar</h1>

                <SectionCard title="Scheduled Jobs" iconColor="#8b5cf6">
                    <div css={styles.eventList}>
                        {loading ? (
                            <div style={{ textAlign: 'center', padding: '20px' }}>Loading events...</div>
                        ) : Object.keys(groupedEvents).length === 0 ? (
                            <div style={{ textAlign: 'center', padding: '20px', color: '#6b7280' }}>No scheduled jobs found.</div>
                        ) : (
                            Object.keys(groupedEvents).sort().map(date => (
                                <div key={date}>
                                    <div css={styles.dateHeader}>
                                        {new Date(date).toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                                    </div>
                                    {(groupedEvents[date] || []).map(event => (
                                        <div
                                            key={event.id}
                                            css={styles.eventCard}
                                            onClick={() => setSelectedEvent(event)}
                                            style={{ cursor: 'pointer' }}
                                        >
                                            <div>
                                                <div style={{ fontWeight: '600' }}>{event.title}</div>
                                                <div style={{ fontSize: '14px', color: '#6b7280' }}>{event.metadata.client}</div>
                                            </div>
                                            <Badge variant="info" size="sm" className={css({ textTransform: 'capitalize' }).toString()}>
                                                {event.status}
                                            </Badge>
                                        </div>
                                    ))}
                                </div>
                            ))
                        )}
                    </div>
                </SectionCard>
            </div>

            <Modal
                isOpen={!!selectedEvent}
                onClose={() => setSelectedEvent(null)}
                title="Event Details"
            >
                {selectedEvent && (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                        <div>
                            <label style={{ fontSize: '12px', color: '#6b7280' }}>Title</label>
                            <div style={{ fontWeight: '500' }}>{selectedEvent.title}</div>
                        </div>
                        <div>
                            <label style={{ fontSize: '12px', color: '#6b7280' }}>Date</label>
                            <div>{selectedEvent.date}</div>
                        </div>
                        <div>
                            <label style={{ fontSize: '12px', color: '#6b7280' }}>Client</label>
                            <div>{selectedEvent.metadata.client}</div>
                        </div>
                        <div>
                            <label style={{ fontSize: '12px', color: '#6b7280' }}>Status</label>
                            <div>
                                <Badge variant="info" size="sm" className={css({ textTransform: 'capitalize' }).toString()}>
                                    {selectedEvent.status}
                                </Badge>
                            </div>
                        </div>
                        <div style={{ marginTop: '16px', display: 'flex', justifyContent: 'flex-end' }}>
                            <Button variant="ghost" onClick={() => setSelectedEvent(null)}>Close</Button>
                        </div>
                    </div>
                )}
            </Modal>
        </>
    );
};

AdminCalendarPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default AdminCalendarPage;
