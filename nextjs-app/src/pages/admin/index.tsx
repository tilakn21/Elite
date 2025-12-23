import { type ReactElement, memo, useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';
import { useTheme, css } from '@emotion/react';
import { AppLayout } from '@/components/layout';
import { StatCard, WelcomeHeader, SectionCard } from '@/components/dashboard';
import { Table, Button } from '@/components/ui';
import { getDashboardStats, getRecentJobs, getTodaysAppointments, getStuckJobs, getRecentActivity, type ActivityItem } from '@/services';
import { getUnpaidReimbursementsTotal } from '@/services/reimbursements.service';
import type { DashboardStats, JobSummary } from '@/types';
import type { NextPageWithLayout } from '../_app';
import * as styles from '@/styles/pages/admin/styles';

/**
 * Admin Dashboard Page
 * Enhanced with Quick Stats and Activity Log
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
  calendar: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
      <line x1="16" y1="2" x2="16" y2="6" />
      <line x1="8" y1="2" x2="8" y2="6" />
      <line x1="3" y1="10" x2="21" y2="10" />
    </svg>
  ),
  warning: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
      <line x1="12" y1="9" x2="12" y2="13" />
      <line x1="12" y1="17" x2="12.01" y2="17" />
    </svg>
  ),
  money: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <line x1="12" y1="1" x2="12" y2="23" />
      <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
    </svg>
  ),
  activity: (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="24" height="24">
      <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
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

// Quick Stats styles
const quickStatsStyles = {
  container: css`
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    margin-bottom: 32px;
    
    @media (max-width: 768px) {
      grid-template-columns: 1fr;
    }
  `,
  card: (color: string, isClickable: boolean) => css`
    background: linear-gradient(135deg, ${color}15 0%, ${color}08 100%);
    border: 1px solid ${color}30;
    border-radius: 16px;
    padding: 24px;
    display: flex;
    align-items: center;
    gap: 16px;
    transition: all 0.3s ease;
    cursor: ${isClickable ? 'pointer' : 'default'};
    
    ${isClickable && `
      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 24px ${color}20;
        border-color: ${color}50;
      }
    `}
  `,
  iconWrapper: (color: string) => css`
    width: 56px;
    height: 56px;
    border-radius: 14px;
    background: ${color};
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    flex-shrink: 0;
  `,
  content: css`
    flex: 1;
    min-width: 0;
  `,
  label: css`
    font-size: 14px;
    color: #64748b;
    margin-bottom: 4px;
  `,
  value: css`
    font-size: 28px;
    font-weight: 700;
    color: #1e293b;
    line-height: 1.2;
  `,
  subtext: css`
    font-size: 12px;
    color: #94a3b8;
    margin-top: 4px;
  `,
};

// Activity Log styles
const activityStyles = {
  container: css`
    max-height: 360px;
    overflow-y: auto;
    
    &::-webkit-scrollbar {
      width: 6px;
    }
    &::-webkit-scrollbar-track {
      background: #f1f5f9;
      border-radius: 3px;
    }
    &::-webkit-scrollbar-thumb {
      background: #cbd5e1;
      border-radius: 3px;
    }
  `,
  item: css`
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid #f1f5f9;
    
    &:last-child {
      border-bottom: none;
    }
  `,
  dot: (color: string) => css`
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: ${color};
    flex-shrink: 0;
    margin-top: 5px;
  `,
  content: css`
    flex: 1;
    min-width: 0;
  `,
  title: css`
    font-size: 14px;
    font-weight: 500;
    color: #1e293b;
    margin-bottom: 2px;
    
    span {
      color: #6366f1;
      font-weight: 600;
    }
  `,
  meta: css`
    font-size: 12px;
    color: #94a3b8;
    display: flex;
    gap: 8px;
    align-items: center;
  `,
  badge: (color: string) => css`
    display: inline-flex;
    align-items: center;
    padding: 2px 8px;
    background: ${color}15;
    color: ${color};
    border-radius: 4px;
    font-size: 11px;
    font-weight: 500;
  `,
};

// Quick Stats data interface
interface QuickStatsData {
  todaysAppointments: number;
  stuckJobsCount: number;
  unpaidReimbursements: { count: number; total: number };
}

// Quick Stats component
const QuickStatsSection = memo(function QuickStatsSection({
  data,
  loading,
  onStuckJobsClick
}: {
  data: QuickStatsData;
  loading: boolean;
  onStuckJobsClick: () => void;
}) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-GB', {
      style: 'currency',
      currency: 'GBP',
      maximumFractionDigits: 0
    }).format(amount);
  };

  const stats = [
    {
      label: "Today's Appointments",
      value: loading ? '...' : data.todaysAppointments.toString(),
      subtext: 'Scheduled for today',
      icon: icons.calendar,
      color: '#0ea5e9',
      onClick: undefined,
    },
    {
      label: 'Jobs Requiring Attention',
      value: loading ? '...' : data.stuckJobsCount.toString(),
      subtext: 'Stuck for > 3 days',
      icon: icons.warning,
      color: data.stuckJobsCount > 0 ? '#f59e0b' : '#10b981',
      onClick: data.stuckJobsCount > 0 ? onStuckJobsClick : undefined,
    },
    {
      label: 'Unpaid Reimbursements',
      value: loading ? '...' : formatCurrency(data.unpaidReimbursements.total),
      subtext: `${data.unpaidReimbursements.count} pending payment${data.unpaidReimbursements.count !== 1 ? 's' : ''}`,
      icon: icons.money,
      color: data.unpaidReimbursements.count > 0 ? '#ef4444' : '#10b981',
      onClick: undefined,
    },
  ];

  return (
    <div style={{ marginBottom: 32 }}>
      <h3 css={styles.sectionTitle}>Quick Stats</h3>
      <div css={quickStatsStyles.container}>
        {stats.map((stat) => (
          <div
            key={stat.label}
            css={quickStatsStyles.card(stat.color, !!stat.onClick)}
            onClick={stat.onClick}
          >
            <div css={quickStatsStyles.iconWrapper(stat.color)}>
              {stat.icon}
            </div>
            <div css={quickStatsStyles.content}>
              <div css={quickStatsStyles.label}>{stat.label}</div>
              <div css={quickStatsStyles.value}>{stat.value}</div>
              <div css={quickStatsStyles.subtext}>{stat.subtext}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
});

// Activity Log component
const ActivityLog = memo(function ActivityLog({
  activities,
  loading
}: {
  activities: ActivityItem[];
  loading: boolean;
}) {
  const getDepartmentColor = (dept: string): string => {
    const colors: Record<string, string> = {
      'Reception': '#ec4899',
      'Sales': '#f59e0b',
      'Design': '#8b5cf6',
      'Production': '#6366f1',
      'Printing': '#0ea5e9',
      'Delivery': '#10b981',
    };
    return colors[dept] || '#64748b';
  };

  const formatTime = (timestamp: string): string => {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const mins = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (mins < 60) return `${mins}m ago`;
    if (hours < 24) return `${hours}h ago`;
    if (days < 7) return `${days}d ago`;
    return date.toLocaleDateString();
  };

  if (loading) {
    return <div style={{ padding: 20, textAlign: 'center', color: '#94a3b8' }}>Loading activity...</div>;
  }

  if (activities.length === 0) {
    return <div style={{ padding: 20, textAlign: 'center', color: '#94a3b8' }}>No recent activity</div>;
  }

  return (
    <div css={activityStyles.container}>
      {activities.map((activity, index) => (
        <div key={`${activity.id}-${index}`} css={activityStyles.item}>
          <div css={activityStyles.dot(getDepartmentColor(activity.department))} />
          <div css={activityStyles.content}>
            <div css={activityStyles.title}>
              <span>{activity.jobCode}</span> — {activity.action}
            </div>
            <div css={activityStyles.meta}>
              <span css={activityStyles.badge(getDepartmentColor(activity.department))}>
                {activity.department}
              </span>
              <span>{formatTime(activity.timestamp)}</span>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
});

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
  activities,
  loading,
  onJobClick
}: {
  jobs: JobSummary[];
  activities: ActivityItem[];
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
      <div>
        <SectionCard
          title="Activity Log"
          icon={icons.activity}
          iconColor="#8B5CF6"
        >
          <ActivityLog activities={activities} loading={loading} />
        </SectionCard>
        <div style={{ marginTop: 24 }}>
          <SectionCard
            title="Quick Actions"
            icon={icons.progress}
            iconColor="#0EA5E9"
          >
            <QuickActions />
          </SectionCard>
        </div>
      </div>
    </div>
  );
});

// Main Dashboard component
const AdminDashboardContent = memo(function AdminDashboardContent() {
  const theme = useTheme();
  const router = useRouter();
  const [stats, setStats] = useState<DashboardStats>({ totalJobs: 0, inProgress: 0, completed: 0, pending: 0 });
  const [jobs, setJobs] = useState<JobSummary[]>([]);
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [quickStats, setQuickStats] = useState<QuickStatsData>({
    todaysAppointments: 0,
    stuckJobsCount: 0,
    unpaidReimbursements: { count: 0, total: 0 },
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const [statsData, jobsData, appointmentsCount, stuckJobsData, unpaidData, activityData] = await Promise.all([
          getDashboardStats(),
          getRecentJobs(5),
          getTodaysAppointments(),
          getStuckJobs(),
          getUnpaidReimbursementsTotal(),
          getRecentActivity(10),
        ]);
        setStats(statsData);
        setJobs(jobsData);
        setActivities(activityData);
        setQuickStats({
          todaysAppointments: appointmentsCount,
          stuckJobsCount: stuckJobsData.count,
          unpaidReimbursements: unpaidData,
        });
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

  const handleStuckJobsClick = () => {
    router.push('/admin/jobs?filter=stuck');
  };

  return (
    <div css={styles.container(theme)}>
      <WelcomeHeader
        title="Admin Dashboard"
        subtitle="Monitor and manage your business operations"
      />
      <StatsGrid stats={stats} loading={loading} />

      {/* Quick Stats Section */}
      <QuickStatsSection
        data={quickStats}
        loading={loading}
        onStuckJobsClick={handleStuckJobsClick}
      />

      {/* Portal Access Section */}
      <PortalAccess />

      <ContentGrid
        jobs={jobs}
        activities={activities}
        loading={loading}
        onJobClick={handleJobClick}
      />
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
