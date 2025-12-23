import { memo, useCallback } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { useAuth, type UserRole } from '@/state';
import { ROUTES } from '@/utils/constants';
import {
    sidebarContainer,
    logo,
    divider,
    navList,
    navItem,
    navLabel,
    userSectionStyles,
    userInfo,
    userAvatar,
    userDetails,
    userNameStyles,
    userRoleStyles,
    logoutButton,
} from './styles';

/**
 * Sidebar Component
 * Desktop navigation matching Flutter's NavigationRail
 */

// Icons
const DashboardIcon = memo(function DashboardIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="3" y="3" width="7" height="7" rx="1" />
            <rect x="14" y="3" width="7" height="7" rx="1" />
            <rect x="14" y="14" width="7" height="7" rx="1" />
            <rect x="3" y="14" width="7" height="7" rx="1" />
        </svg>
    );
});

const JobsIcon = memo(function JobsIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01" />
        </svg>
    );
});

const UploadIcon = memo(function UploadIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="17 8 12 3 7 8" />
            <line x1="12" y1="3" x2="12" y2="15" />
        </svg>
    );
});

const ChatIcon = memo(function ChatIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
        </svg>
    );
});

const CalendarIcon = memo(function CalendarIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
            <line x1="16" y1="2" x2="16" y2="6" />
            <line x1="8" y1="2" x2="8" y2="6" />
            <line x1="3" y1="10" x2="21" y2="10" />
        </svg>
    );
});

const EmployeesIcon = memo(function EmployeesIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
            <circle cx="9" cy="7" r="4" />
            <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
            <path d="M16 3.13a4 4 0 0 1 0 7.75" />
        </svg>
    );
});

const ReimbursementIcon = memo(function ReimbursementIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <rect x="1" y="4" width="22" height="16" rx="2" ry="2" />
            <line x1="1" y1="10" x2="23" y2="10" />
        </svg>
    );
});

const InvoiceIcon = memo(function InvoiceIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
            <polyline points="14 2 14 8 20 8" />
            <line x1="16" y1="13" x2="8" y2="13" />
            <line x1="16" y1="17" x2="8" y2="17" />
            <polyline points="10 9 9 9 8 9" />
        </svg>
    );
});

const LogoutIcon = memo(function LogoutIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
        </svg>
    );
});

// Icon mapping type
type IconComponent = React.ComponentType;

// Navigation configuration by role
const getNavItems = (role: UserRole | undefined): { href: string; label: string; icon: IconComponent }[] => {
    switch (role) {
        case 'admin':
            return [
                { href: ROUTES.ADMIN_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.ADMIN_EMPLOYEES, label: 'Employees', icon: EmployeesIcon },
                { href: ROUTES.ADMIN_JOBS, label: 'Job Listing', icon: JobsIcon },
                { href: ROUTES.ADMIN_CALENDAR, label: 'Calendar', icon: CalendarIcon },
                { href: ROUTES.ADMIN_REIMBURSEMENTS, label: 'Reimbursements', icon: ReimbursementIcon },
            ];
        case 'receptionist':
            return [
                { href: ROUTES.RECEPTIONIST_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.RECEPTIONIST_NEW_JOB, label: 'New Job Request', icon: UploadIcon },
                { href: ROUTES.RECEPTIONIST_JOBS, label: 'View All Jobs', icon: JobsIcon },
                { href: ROUTES.RECEPTIONIST_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        case 'design':
            return [
                { href: ROUTES.DESIGN_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.DESIGN_JOBS, label: 'Job Details', icon: JobsIcon },
                { href: ROUTES.DESIGN_CHATS, label: 'Chat', icon: ChatIcon },
                { href: ROUTES.DESIGN_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        case 'production':
            return [
                { href: ROUTES.PRODUCTION_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.PRODUCTION_JOBS, label: 'Job List', icon: JobsIcon },
                { href: ROUTES.PRODUCTION_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        case 'printing':
            return [
                { href: ROUTES.PRINTING_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.PRINTING_JOBS, label: 'Job Queue', icon: JobsIcon },
            ];
        case 'accounts':
            return [
                { href: ROUTES.ACCOUNTS_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.ACCOUNTS_INVOICES, label: 'Invoices', icon: InvoiceIcon },
                { href: ROUTES.ACCOUNTS_EMPLOYEES, label: 'Employees', icon: EmployeesIcon },
                { href: ROUTES.ACCOUNTS_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        case 'salesperson':
            return [
                { href: ROUTES.SALESPERSON_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.SALESPERSON_PROFILE, label: 'Profile', icon: EmployeesIcon },
                { href: ROUTES.SALESPERSON_REIMBURSEMENT, label: 'Reimbursement', icon: ReimbursementIcon },
                { href: ROUTES.SALESPERSON_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        default:
            return [];
    }
};

export interface SidebarProps {
    collapsed?: boolean;
}

export const Sidebar = memo(function Sidebar({ collapsed = false }: SidebarProps) {
    const { state: authState, logout } = useAuth();
    const router = useRouter();
    const theme = useTheme();

    const user = authState.user;
    const navItems = getNavItems(user?.role);

    const initials = user?.name
        ? user.name
            .split(' ')
            .map((n) => n[0])
            .join('')
            .toUpperCase()
            .slice(0, 2)
        : '?';

    const handleLogout = useCallback(async () => {
        await logout();
        router.push(ROUTES.LOGIN);
    }, [logout, router]);

    return (
        <aside css={sidebarContainer(collapsed, theme)}>
            <div css={logo(theme)}>
                <img src="/images/elite_logo.png" alt="Elite" style={{ height: 'auto', width: 'auto' }} />
            </div>

            <hr css={divider} />

            <nav css={navList(theme)}>
                {navItems.map((item) => {
                    const Icon = item.icon;
                    const isActive = router.pathname === item.href;

                    return (
                        <Link key={item.href} href={item.href} css={navItem(isActive, theme)}>
                            <Icon />
                            {!collapsed && <span css={navLabel}>{item.label}</span>}
                        </Link>
                    );
                })}
            </nav>

            <div css={userSectionStyles(theme)}>
                <div css={userInfo(theme)}>
                    <div css={userAvatar(theme)}>{initials}</div>
                    {!collapsed && (
                        <div css={userDetails}>
                            <div css={userNameStyles(theme)}>{user?.name}</div>
                            <div css={userRoleStyles(theme)}>{user?.role}</div>
                        </div>
                    )}
                </div>
            </div>

            <button css={logoutButton(theme)} onClick={handleLogout}>
                <LogoutIcon />
                {!collapsed && 'Logout'}
            </button>
        </aside>
    );
});

export default Sidebar;
