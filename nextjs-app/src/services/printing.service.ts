/**
 * Printing Service
 * Handles interactions for the Printing Dashboard
 */

import { } from './supabase';
import type { PrintingJob, PrintingJobStatus, PrintingStats } from '@/types/printing';

// Mock data for development until backend is fully ready
const MOCK_PRINTING_JOBS: PrintingJob[] = [
    {
        id: 'pj-1',
        jobCode: 'JB-5001',
        customerName: 'TechCorp Inc.',
        description: 'Large format banner for conference',
        material: 'Vinyl Flex',
        dimensions: '12x6 ft',
        status: 'ready_for_print',
        priority: 'high',
        quantity: 1,
        files: ['https://placehold.co/600x400?text=Banner+Design'],
        createdAt: new Date().toISOString()
    },
    {
        id: 'pj-2',
        jobCode: 'JB-5002',
        customerName: 'Cafe Delight',
        description: 'Window stickers',
        material: 'Vinyl Sticker (Matte)',
        dimensions: '2x2 ft',
        status: 'printing',
        priority: 'medium',
        quantity: 20,
        files: ['https://placehold.co/600x400?text=Sticker'],
        createdAt: new Date().toISOString(),
        startedAt: new Date().toISOString()
    },
    {
        id: 'pj-3',
        jobCode: 'JB-5003',
        customerName: 'Auto World',
        description: 'Backlit board skin',
        material: 'Backlit Flex',
        dimensions: '8x4 ft',
        status: 'ready_for_print',
        priority: 'low',
        quantity: 1,
        files: ['https://placehold.co/600x400?text=Board'],
        createdAt: new Date().toISOString()
    }
];

class PrintingService {
    /**
     * Get dashboard stats (Mocked)
     */
    async getStats(): Promise<PrintingStats> {
        return {
            jobsInQueue: 5,
            completedToday: 12,
            inkLevelCyan: 85,
            inkLevelMagenta: 45,
            inkLevelYellow: 90,
            inkLevelBlack: 60,
            activePrinters: 2
        };
    }

    /**
     * Get list of printing jobs
     */
    async getPrintingJobs(statusFilter?: PrintingJobStatus | 'all'): Promise<PrintingJob[]> {
        // In real impl, fetch from Supabase
        // const { data } = await supabase.from('production_jobs').select('*').in('status', ['ready_for_print', 'printing', 'completed']);

        return new Promise((resolve) => {
            setTimeout(() => {
                if (!statusFilter || statusFilter === 'all') {
                    resolve(MOCK_PRINTING_JOBS);
                } else {
                    resolve(MOCK_PRINTING_JOBS.filter(job => job.status === statusFilter));
                }
            }, 500);
        });
    }

    /**
     * Update job status
     */
    async updateStatus(jobId: string, status: PrintingJobStatus): Promise<boolean> {
        console.log(`Updating job ${jobId} to ${status}`);
        // await supabase.from('jobs').update({ status }).eq('id', jobId);
        return true;
    }
}

export const printingService = new PrintingService();
