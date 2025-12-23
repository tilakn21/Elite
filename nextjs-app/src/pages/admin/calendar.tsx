import { type ReactElement, useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme, css, Theme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { ScheduleCalendar } from '@/components/calendar';
import { getCalendarEvents } from '@/services';
import type { CalendarEvent } from '@/types';
import type { NextPageWithLayout } from '../_app';

/**
 * Admin Calendar Page
 * Hybrid schedule calendar with mini month picker and agenda view
 */

const containerStyles = (theme: Theme) => css`
    padding: 32px;
    max-width: 1400px;
    margin: 0 auto;
    background: ${theme.colors.background};
    min-height: 100vh;
`;

const headerStyles = css`
    margin-bottom: 24px;
    
    h1 {
        font-size: 28px;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 8px;
    }
    
    p {
        color: #64748b;
        font-size: 15px;
    }
`;

const AdminCalendarPage: NextPageWithLayout = () => {
    const theme = useTheme();
    const router = useRouter();
    const [events, setEvents] = useState<CalendarEvent[]>([]);
    const [loading, setLoading] = useState(true);

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

    const handleEventClick = (event: CalendarEvent) => {
        router.push(`/admin/jobs/${event.id}`);
    };

    return (
        <>
            <Head>
                <title>Calendar | Elite Signboard</title>
            </Head>

            <div css={containerStyles(theme)}>
                <div css={headerStyles}>
                    <h1>Calendar</h1>
                    <p>View and manage all scheduled jobs. Click on a date to see appointments.</p>
                </div>

                <ScheduleCalendar
                    events={events}
                    onEventClick={handleEventClick}
                    loading={loading}
                />
            </div>
        </>
    );
};

AdminCalendarPage.getLayout = (page: ReactElement) => (
    <AppLayout variant="dashboard">{page}</AppLayout>
);

export default AdminCalendarPage;
