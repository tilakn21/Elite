/**
 * Calendar Service
 * Handles calendar event data, primarily mapping jobs to events
 */

import { supabase } from './supabase';
import type { CalendarEvent } from '@/types';

/**
 * Parse JSONB field from Supabase response
 */
function parseJsonField<T>(field: unknown): T | null {
    if (!field) return null;
    if (typeof field === 'object') return field as T;
    if (typeof field === 'string') {
        try {
            return JSON.parse(field) as T;
        } catch {
            return null;
        }
    }
    return null;
}

/**
 * Get calendar events for a specific month
 * Fetches jobs and maps them to calendar events
 */
export async function getCalendarEvents(month?: Date): Promise<CalendarEvent[]> {
    try {
        // Calculate date range for the month (with buffer for prev/next month display)
        const targetMonth = month || new Date();
        const startDate = new Date(targetMonth.getFullYear(), targetMonth.getMonth() - 1, 1);
        const endDate = new Date(targetMonth.getFullYear(), targetMonth.getMonth() + 2, 0);

        const { data, error } = await supabase
            .from('jobs')
            .select('id, job_code, status, receptionist, created_at')
            .gte('created_at', startDate.toISOString())
            .lte('created_at', endDate.toISOString())
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching calendar events:', error);
            return [];
        }

        return (data ?? []).map((job) => {
            const receptionist = parseJsonField<Record<string, unknown>>(job.receptionist);
            return {
                id: job.id,
                title: `Job #${job.job_code}`,
                date: (job.created_at || new Date().toISOString()).split('T')[0] ?? '',
                type: 'job' as const,
                status: job.status,
                metadata: {
                    jobCode: job.job_code,
                    client: (receptionist?.customerName as string) ?? (receptionist?.client_name as string) ?? 'Unknown Client',
                    shopName: (receptionist?.shopName as string) ?? '',
                },
            };
        });
    } catch (error) {
        console.error('Error in getCalendarEvents:', error);
        return [];
    }
}

/**
 * Get jobs for a specific date
 */
export async function getJobsByDate(date: string): Promise<CalendarEvent[]> {
    try {
        const startOfDay = `${date}T00:00:00.000Z`;
        const endOfDay = `${date}T23:59:59.999Z`;

        const { data, error } = await supabase
            .from('jobs')
            .select('id, job_code, status, receptionist, created_at')
            .gte('created_at', startOfDay)
            .lte('created_at', endOfDay)
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching jobs by date:', error);
            return [];
        }

        return (data ?? []).map((job) => {
            const receptionist = parseJsonField<Record<string, unknown>>(job.receptionist);
            return {
                id: job.id,
                title: `Job #${job.job_code}`,
                date: (job.created_at || new Date().toISOString()).split('T')[0] ?? '',
                type: 'job' as const,
                status: job.status,
                metadata: {
                    jobCode: job.job_code,
                    client: (receptionist?.customerName as string) ?? (receptionist?.client_name as string) ?? 'Unknown Client',
                    shopName: (receptionist?.shopName as string) ?? '',
                },
            };
        });
    } catch (error) {
        console.error('Error in getJobsByDate:', error);
        return [];
    }
}
