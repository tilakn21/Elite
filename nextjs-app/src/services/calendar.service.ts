/**
 * Calendar Service
 * Handles calendar event data, primarily mapping jobs to events
 */

import { getJobs } from './jobs.service';
import type { CalendarEvent, Job } from '@/types';

/**
 * Get calendar events mapped from jobs
 * Admin sees all jobs
 */
// eslint-disable-next-line @typescript-eslint/no-unused-vars
export async function getCalendarEvents(_month: Date): Promise<CalendarEvent[]> {
    // Calculate start/end dates for the month
    // For now, we fetch recent jobs and map them
    // In a real app, we'd filter query by date range

    try {
        const { jobs } = await getJobs();

        return jobs.map((job: Job) => ({
            id: job.id,
            title: `Job #${job.job_code}`,
            date: (job.created_at || new Date().toISOString()).split('T')[0] ?? '',
            type: 'job',
            status: job.status,
            metadata: {
                jobCode: job.job_code,
                client: job.receptionist?.client_name ?? job.receptionist?.customerName ?? 'Unknown Client',
            },
        }));
    } catch (error) {
        console.error('Error fetching calendar events:', error);
        return [];
    }
}
