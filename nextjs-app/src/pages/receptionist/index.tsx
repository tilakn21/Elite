/**
 * Receptionist Dashboard - Main Overview
 * Shows stats cards, recent job requests, salesperson allocation, and calendar
 */

import { useState, useEffect } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { useAuth } from '@/state';
import { receptionistService } from '@/services/receptionist.service';
import type { JobRequest, Salesperson, ReceptionistStats, ReceptionistProfile } from '@/types/receptionist';
import * as styles from '@/styles/pages/receptionist/styles';

export default function ReceptionistDashboard() {
    const theme = useTheme();
    const { state: authState } = useAuth();

    const [isLoading, setIsLoading] = useState(true);
    const [profile, setProfile] = useState<ReceptionistProfile | null>(null);
    const [stats, setStats] = useState<ReceptionistStats | null>(null);
    const [recentJobs, setRecentJobs] = useState<JobRequest[]>([]);
    const [salespersons, setSalespersons] = useState<Salesperson[]>([]);

    const receptionistId = authState.user?.employeeId;

    useEffect(() => {
        async function loadData() {
            if (!receptionistId) {
                setIsLoading(false);
                return;
            }

            try {
                const [profileData, statsData, jobsData, salesData] = await Promise.all([
                    receptionistService.getReceptionistProfile(receptionistId),
                    receptionistService.getDashboardStats(),
                    receptionistService.getJobRequests(),
                    receptionistService.getSalespersons(),
                ]);

                setProfile(profileData);
                setStats(statsData);
                setRecentJobs(jobsData.slice(0, 5)); // Show latest 5 jobs
                setSalespersons(salesData.slice(0, 6)); // Show top 6 salespersons
            } catch (error) {
                console.error('Failed to load dashboard data:', error);
            } finally {
                setIsLoading(false);
            }
        }

        loadData();
    }, [receptionistId]);

    const getInitials = (name: string) => {
        return name
            .split(' ')
            .map(n => n[0])
            .join('')
            .toUpperCase()
            .slice(0, 2);
    };

    const formatTime = (dateString: string) => {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    };

    if (isLoading) {
        return (
            <>
                <Head>
                    <title>Dashboard | Elite Signboard</title>
                </Head>
                <AppLayout variant="dashboard">
                    <div css={styles.loadingContainer}>
                        <div css={styles.spinnerAnimation} />
                    </div>
                </AppLayout>
            </>
        );
    }

    return (
        <>
            <Head>
                <title>Dashboard | Elite Signboard</title>
            </Head>

            <AppLayout variant="dashboard">
                <div css={styles.pageContainer(theme)}>
                    {/* Greeting */}
                    <div css={styles.greeting}>
                        <h1>Hello, {profile?.fullName || 'Receptionist'}!</h1>
                        <p>{profile?.branchName || 'Branch'} • {new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long' })}</p>
                    </div>

                    {/* Stats Cards */}
                    <div css={styles.statsGrid}>
                        <div css={styles.statCard('#5A6CEA')}>
                            <h3>{stats?.totalJobs ?? 0}</h3>
                            <p>Total Jobs</p>
                        </div>
                        <Link href="/receptionist/jobs?status=pending" css={styles.statCardClickable('#F59E0B')}>
                            <h3>{stats?.pendingJobs ?? 0}</h3>
                            <p>Pending</p>
                        </Link>
                        <Link href="/receptionist/jobs?status=assigned" css={styles.statCardClickable('#8B5CF6')}>
                            <h3>{stats?.assignedToday ?? 0}</h3>
                            <p>Assigned Today</p>
                        </Link>
                    </div>

                    {/* Main Grid */}
                    <div css={styles.mainGrid}>
                        {/* Recent Job Requests */}
                        <div css={styles.card}>
                            <div css={styles.cardHeader}>
                                <h2>Recent Job Requests</h2>
                                <Link href="/receptionist/jobs">View All Jobs</Link>
                            </div>

                            {recentJobs.length === 0 ? (
                                <div css={styles.emptyState}>No job requests yet</div>
                            ) : (
                                <div css={styles.jobList}>
                                    {recentJobs.map(job => (
                                        <div key={job.id} css={styles.jobItem}>
                                            <div className="avatar">
                                                {getInitials(job.customerName)}
                                            </div>
                                            <div className="info">
                                                <div className="name">{job.customerName}</div>
                                                <div className="shop">{job.shopName || 'No shop name'}</div>
                                            </div>
                                            <span className="time">{formatTime(job.dateAdded)}</span>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Salesperson Allocation */}
                        <div css={styles.card}>
                            <div css={styles.cardHeader}>
                                <h2>Salesperson Allocation</h2>
                                <Link href="/receptionist/new-job">Assign New Job</Link>
                            </div>

                            {salespersons.length === 0 ? (
                                <div css={styles.emptyState}>No salespersons available</div>
                            ) : (
                                <div css={styles.salespersonList}>
                                    {salespersons.map(sp => (
                                        <div key={sp.id} css={styles.salespersonItem}>
                                            <div className="avatar">
                                                {getInitials(sp.name)}
                                            </div>
                                            <div className="info">
                                                <div className="name">{sp.name}</div>
                                                <div className="jobs">{sp.numberOfJobs} jobs assigned</div>
                                            </div>
                                            <span css={styles.statusBadge(sp.isAvailable)}>
                                                {sp.isAvailable ? 'Available' : 'Busy'}
                                            </span>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </AppLayout>
        </>
    );
}

