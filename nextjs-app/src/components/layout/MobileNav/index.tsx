import { memo, useCallback } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { useAuth, type UserRole } from '@/state';
import { useUI } from '@/state/ui';
import { ROUTES } from '@/utils/constants';
import { navContainer, mobileNavItem, mobileNavLabel } from './styles';

/**
 * MobileNav Component
 * Bottom navigation bar for mobile devices
 */

// Icons (memoized for performance)
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
        </svg>
    );
});

// Icon mapping type
type IconComponent = React.ComponentType;

// Mobile nav items by role
const getMobileNavItems = (role: UserRole | undefined): { href: string; label: string; icon: IconComponent }[] => {
    switch (role) {
        case 'admin':
            return [
                { href: ROUTES.ADMIN_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.ADMIN_EMPLOYEES, label: 'Employees', icon: EmployeesIcon },
                { href: ROUTES.ADMIN_JOBS, label: 'Jobs', icon: JobsIcon },
                { href: ROUTES.ADMIN_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        case 'receptionist':
            return [
                { href: ROUTES.RECEPTIONIST_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.RECEPTIONIST_NEW_JOB, label: 'New Job', icon: UploadIcon },
                { href: ROUTES.RECEPTIONIST_JOBS, label: 'Jobs', icon: JobsIcon },
                { href: ROUTES.RECEPTIONIST_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        case 'design':
            return [
                { href: ROUTES.DESIGN_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.DESIGN_JOBS, label: 'Jobs', icon: JobsIcon },
                { href: '/design/upload', label: 'Upload', icon: UploadIcon },
                { href: ROUTES.DESIGN_CHATS, label: 'Chat', icon: ChatIcon },
            ];
        case 'production':
            return [
                { href: ROUTES.PRODUCTION_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.PRODUCTION_JOBS, label: 'Jobs', icon: JobsIcon },
                { href: ROUTES.PRODUCTION_CALENDAR, label: 'Calendar', icon: CalendarIcon },
            ];
        case 'printing':
            return [
                { href: ROUTES.PRINTING_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.PRINTING_JOBS, label: 'Queue', icon: JobsIcon },
            ];
        case 'accounts':
            return [
                { href: ROUTES.ACCOUNTS_DASHBOARD, label: 'Dashboard', icon: DashboardIcon },
                { href: ROUTES.ACCOUNTS_JOBS, label: 'Jobs', icon: JobsIcon },
                { href: ROUTES.ACCOUNTS_INVOICES, label: 'Invoices', icon: UploadIcon },
                { href: ROUTES.ACCOUNTS_PAYMENTS, label: 'Payments', icon: EmployeesIcon },
            ];
        case 'salesperson':
            return [
                { href: ROUTES.SALESPERSON_DASHBOARD, label: 'Home', icon: DashboardIcon },
                { href: ROUTES.SALESPERSON_CALENDAR, label: 'Calendar', icon: CalendarIcon },
                { href: ROUTES.SALESPERSON_REIMBURSEMENT, label: 'Claims', icon: UploadIcon }, // Using UploadIcon for claims/reimbursement
                { href: ROUTES.SALESPERSON_PROFILE, label: 'Profile', icon: EmployeesIcon },
            ];
        default:
            return [];
    }
};

export const MobileNav = memo(function MobileNav() {
    const { state: authState } = useAuth();
    const { closeMobileNav } = useUI();
    const router = useRouter();
    const theme = useTheme();

    const user = authState.user;
    const navItems = getMobileNavItems(user?.role);

    const handleNavClick = useCallback(() => {
        closeMobileNav();
    }, [closeMobileNav]);

    return (
        <nav css={navContainer(theme)}>
            {navItems.map((item) => {
                const Icon = item.icon;
                const isActive = router.pathname === item.href;

                return (
                    <Link
                        key={item.href}
                        href={item.href}
                        css={mobileNavItem(isActive, theme)}
                        onClick={handleNavClick}
                    >
                        <Icon />
                        <span css={mobileNavLabel}>{item.label}</span>
                    </Link>
                );
            })}
        </nav>
    );
});

export default MobileNav;
