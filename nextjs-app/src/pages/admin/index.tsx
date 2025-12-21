import { type ReactElement, memo, useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { StatCard, WelcomeHeader, SectionCard } from '@/components/dashboard';
import { Table, Button } from '@/components/ui';
import { getDashboardStats, getRecentJobs } from '@/services';
import type { DashboardStats, JobSummary } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/styles';

/**
 * Admin Dashboard Page
 * Fetches real data from Supabase and displays stats + recent jobs
 */

// Icons for stat cards
const icons = {
  total: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
    </svg>
  ),
  progress: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <circle cx="12" cy="12" r="10" />
      <polyline points="12 6 12 12 16 14" />
    </svg>
  ),
  completed: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
      <polyline points="22 4 12 14.01 9 11.01" />
    </svg>
  ),
  pending: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <circle cx="12" cy="12" r="10" />
      <line x1="12" y1="8" x2="12" y2="12" />
      <line x1="12" y1="16" x2="12.01" y2="16" />
    </svg>
  ),
};

const portalIcons = {
  salesperson: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
      <circle cx="12" cy="7" r="4" />
    </svg>
  ),
  receptionist: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  ),
  design: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <path d="M12 19l7-7 3 3-7 7-3-3z" />
      <path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z" />
      <path d="M2 2l7.586 7.586" />
      <circle cx="11" cy="11" r="2" />
    </svg>
  ),
  production: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <path d="M2 20h.01" />
      <path d="M7 20v-4" />
      <path d="M12 20v-8" />
      <path d="M17 20V8" />
      <path d="M22 4v16" />
    </svg>
  ),
  printing: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <polyline points="6 9 6 2 18 2 18 9" />
      <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2" />
      <rect x="6" y="14" width="12" height="8" />
    </svg>
  ),
  accounts: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <rect x="2" y="5" width="20" height="14" rx="2" />
      <line x1="2" y1="10" x2="22" y2="10" />
    </svg>
  ),
};

// Job columns configuration
const jobColumns = [
  { key: 'job_code', header: 'Job #', width: '100px' },
  { key: 'title', header: 'Title' },
  { key: 'client', header: 'Client' },
  { key: 'status', header: 'Status', width: '120px' },
  { key: 'date', header: 'Date', width: '100px' },
];

// Stats Grid component
const StatsGrid = memo(function StatsGrid({ stats, loading }: { stats: DashboardStats; loading: boolean }) {
  const theme = useTheme();

  const statItems = [
    { label: 'Total Jobs', value: stats.totalJobs.toString(), icon: icons.total, color: '#6366f1' },
    { label: 'In Progress', value: stats.inProgress.toString(), icon: icons.progress, color: '#0ea5e9' },
    { label: 'Completed', value: stats.completed.toString(), icon: icons.completed, color: '#10b981' },
    { label: 'Pending', value: stats.pending.toString(), icon: icons.pending, color: '#f59e0b' },
  ];

  return (
    <div css={styles.statsGrid(theme)}>
      {statItems.map((stat) => (
        <StatCard
          key={stat.label}
          label={stat.label}
          value={loading ? '...' : stat.value}
          change=""
          positive={true}
        />
      ))}
    </div>
  );
});

// Portal Access Component
const PortalAccess = memo(function PortalAccess() {
  const router = useRouter();
  const theme = useTheme();

  const portals = [
    { name: 'Salesperson', path: '/salesperson', icon: portalIcons.salesperson, color: '#F59E0B' },
    { name: 'Receptionist', path: '/receptionist', icon: portalIcons.receptionist, color: '#EC4899' },
    { name: 'Design', path: '/design', icon: portalIcons.design, color: '#8B5CF6' },
    { name: 'Production', path: '/production', icon: portalIcons.production, color: '#6366F1' },
    { name: 'Printing', path: '/printing', icon: portalIcons.printing, color: '#0EA5E9' },
    { name: 'Accounts', path: '/accounts', icon: portalIcons.accounts, color: '#10B981' },
  ];

  return (
    <div style={{ marginBottom: 32 }}>
      <h3 css={styles.sectionTitle}>Portal Access</h3>
      <div css={styles.portalGrid(theme)}>
        {portals.map((portal) => (
          <div
            key={portal.name}
            css={styles.portalCard}
            onClick={() => router.push(portal.path)}
          >
            <div css={styles.iconWrapper(portal.color)}>
              {portal.icon}
            </div>
            <div>
              <h3>{portal.name}</h3>
              <p>Dashboard</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
});

// Quick Actions component
const QuickActions = memo(function QuickActions() {
  const router = useRouter();

  return (
    <div css={styles.quickActions}>
      <Button variant="primary" fullWidth onClick={() => router.push('/admin/employees')}>
        Manage Employees
      </Button>
      <Button variant="outline" fullWidth onClick={() => router.push('/admin/jobs')}>
        View All Jobs
      </Button>
      <Button variant="ghost" fullWidth onClick={() => router.push('/admin/calendar')}>
        Calendar
      </Button>
    </div>
  );
});

// Content Grid component
const ContentGrid = memo(function ContentGrid({
  jobs,
  loading,
  onJobClick
}: {
  jobs: JobSummary[];
  loading: boolean;
  onJobClick: (job: JobSummary) => void;
}) {
  const theme = useTheme();

  return (
    <div css={styles.contentGrid(theme)}>
      <SectionCard
        title="Recent Jobs"
        icon={icons.total}
        iconColor="#10B981"
      >
        <div css={styles.tableWrapper}>
          <Table
            columns={jobColumns}
            data={jobs}
            loading={loading}
            emptyMessage="No jobs found"
            onRowClick={onJobClick}
          />
        </div>
      </SectionCard>
      <SectionCard
        title="Quick Actions"
        icon={icons.progress}
        iconColor="#0EA5E9"
      >
        <QuickActions />
      </SectionCard>
    </div>
  );
});

// Main Dashboard component
const AdminDashboardContent = memo(function AdminDashboardContent() {
  const theme = useTheme();
  const router = useRouter();
  const [stats, setStats] = useState<DashboardStats>({ totalJobs: 0, inProgress: 0, completed: 0, pending: 0 });
  const [jobs, setJobs] = useState<JobSummary[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const [statsData, jobsData] = await Promise.all([
          getDashboardStats(),
          getRecentJobs(5),
        ]);
        setStats(statsData);
        setJobs(jobsData);
      } catch (error) {
        console.error('Error loading dashboard data:', error);
      } finally {
        setLoading(false);
      }
    }

    loadData();
  }, []);

  const handleJobClick = (job: JobSummary) => {
    router.push(`/admin/jobs/${job.id}`);
  };

  return (
    <div css={styles.container(theme)}>
      <WelcomeHeader
        title="Admin Dashboard"
        subtitle="Monitor and manage your business operations"
      />
      <StatsGrid stats={stats} loading={loading} />

      {/* Portal Access Section */}
      <PortalAccess />

      <ContentGrid jobs={jobs} loading={loading} onJobClick={handleJobClick} />
    </div>
  );
});

const AdminDashboard: NextPageWithLayout = () => {
  return (
    <>
      <Head>
        <title>Admin Dashboard | Elite Signboard</title>
        <meta name="description" content="Admin dashboard for Elite Signboard Management" />
      </Head>
      <AdminDashboardContent />
    </>
  );
};

// Use dashboard layout with sidebar
AdminDashboard.getLayout = (page: ReactElement) => (
  <AppLayout variant="dashboard">{page}</AppLayout>
);

export default AdminDashboard;
