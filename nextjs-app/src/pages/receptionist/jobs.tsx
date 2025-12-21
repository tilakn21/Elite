/**
 * Receptionist - View All Jobs
 * Shows list of all job requests with filtering
 */

import { useState, useEffect, useMemo } from 'react';
import Head from 'next/head';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { receptionistService } from '@/services/receptionist.service';
import type { JobRequest, JobRequestStatus } from '@/types/receptionist';
import * as styles from '@/styles/pages/receptionist/jobs.styles';

function SearchIcon() {
    return (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="11" cy="11" r="8" />
            <path d="m21 21-4.35-4.35" />
        </svg>
    );
}

export default function JobsListPage() {
    const theme = useTheme();

    const [jobs, setJobs] = useState<JobRequest[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState<string>('all');

    useEffect(() => {
        async function loadJobs() {
            try {
                const data = await receptionistService.getJobRequests();
                setJobs(data);
            } catch (error) {
                console.error('Failed to load jobs:', error);
            } finally {
                setIsLoading(false);
            }
        }
        loadJobs();
    }, []);

    const filteredJobs = useMemo(() => {
        return jobs.filter(job => {
            const matchesSearch = searchQuery === '' ||
                job.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                job.jobCode.toLowerCase().includes(searchQuery.toLowerCase()) ||
                (job.shopName?.toLowerCase() || '').includes(searchQuery.toLowerCase());

            const matchesStatus = statusFilter === 'all' || job.status === statusFilter;

            return matchesSearch && matchesStatus;
        });
    }, [jobs, searchQuery, statusFilter]);

    const getInitials = (name: string) => {
        return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    };

    const formatDate = (dateString: string) => {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
    };

    const formatStatus = (status: JobRequestStatus) => {
        switch (status) {
            case 'approved': return 'Assigned';
            case 'completed': return 'Completed';
            case 'declined': return 'Declined';
            default: return 'Pending';
        }
    };

    return (
        <>
            <Head>
                <title>All Jobs | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Header */}
                    <div css={styles.header}>
                        <h1>All Job Requests</h1>
                        <div css={styles.controls}>
                            <div css={styles.searchWrapper}>
                                <SearchIcon />
                                <input
                                    type="text"
                                    placeholder="Search by name, job code..."
                                    value={searchQuery}
                                    onChange={e => setSearchQuery(e.target.value)}
                                    css={styles.searchInput(theme)}
                                />
                            </div>
                            <select
                                value={statusFilter}
                                onChange={e => setStatusFilter(e.target.value)}
                                css={styles.filterSelect}
                            >
                                <option value="all">All Status</option>
                                <option value="pending">Pending</option>
                                <option value="approved">Assigned</option>
                                <option value="completed">Completed</option>
                                <option value="declined">Declined</option>
                            </select>
                        </div>
                    </div>

                    {/* Content */}
                    {isLoading ? (
                        <div css={styles.loadingContainer}>
                            <div css={styles.spinnerAnimation} />
                        </div>
                    ) : filteredJobs.length === 0 ? (
                        <div css={styles.tableCard}>
                            <div css={styles.emptyState}>
                                <h3>No jobs found</h3>
                                <p>{searchQuery || statusFilter !== 'all'
                                    ? 'Try adjusting your filters'
                                    : 'No job requests have been created yet'}</p>
                            </div>
                        </div>
                    ) : (
                        <>
                            {/* Desktop Table */}
                            <div css={[styles.tableCard, styles.desktopTable]}>
                                <table css={styles.table}>
                                    <thead>
                                        <tr>
                                            <th>Customer</th>
                                            <th>Job Code</th>
                                            <th>Phone</th>
                                            <th>Date</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {filteredJobs.map(job => (
                                            <tr key={job.id}>
                                                <td>
                                                    <div css={styles.customerCell}>
                                                        <div className="avatar">
                                                            {getInitials(job.customerName)}
                                                        </div>
                                                        <div className="info">
                                                            <div className="name">{job.customerName}</div>
                                                            <div className="shop">{job.shopName || '-'}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>{job.jobCode}</td>
                                                <td>{job.phone || '-'}</td>
                                                <td>{formatDate(job.dateAdded)}</td>
                                                <td>
                                                    <span css={styles.statusBadge(job.status)}>
                                                        {formatStatus(job.status)}
                                                    </span>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>

                            {/* Mobile Cards */}
                            <div css={styles.mobileCard}>
                                {filteredJobs.map(job => (
                                    <div key={job.id} css={styles.mobileJobItem}>
                                        <div className="header">
                                            <div>
                                                <div className="customer">{job.customerName}</div>
                                                <div className="shop">{job.shopName || '-'}</div>
                                            </div>
                                            <span css={styles.statusBadge(job.status)}>
                                                {formatStatus(job.status)}
                                            </span>
                                        </div>
                                        <div className="meta">
                                            <span>#{job.jobCode}</span>
                                            <span>{job.phone || '-'}</span>
                                            <span>{formatDate(job.dateAdded)}</span>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        </>
                    )}
                </div>
            </AppLayout>
        </>
    );
}

