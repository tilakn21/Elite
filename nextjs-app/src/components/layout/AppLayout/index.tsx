import { type ReactNode, useEffect, memo } from 'react';
import { useRouter } from 'next/router';
import { useTheme } from '@emotion/react';
import { Header } from '../Header';
import { Sidebar } from '../Sidebar';
import { MobileNav } from '../MobileNav';
import { useAuth } from '@/state';
import { ROUTES } from '@/utils/constants';
import {
    layoutContainer,
    mainWrapper,
    contentArea,
    authContainer,
    loadingOverlay,
    spinner,
} from './styles';

/**
 * AppLayout Component
 * Main layout wrapper that handles responsive layout:
 * - Desktop: Sidebar + Header + Content
 * - Mobile/Tablet: Header + Content + Bottom Nav
 */

export type LayoutVariant = 'dashboard' | 'auth' | 'minimal';

export interface AppLayoutProps {
    children: ReactNode;
    variant?: LayoutVariant;
    showHeader?: boolean;
    showSearch?: boolean;
}

const Spinner = memo(function Spinner() {
    const theme = useTheme();
    return <div css={spinner(theme)} />;
});

const LoadingOverlayComponent = memo(function LoadingOverlayComponent() {
    const theme = useTheme();
    return (
        <div css={loadingOverlay(theme)}>
            <Spinner />
        </div>
    );
});

export const AppLayout = memo(function AppLayout({
    children,
    variant = 'dashboard',
    showHeader = true,
    showSearch = true,
}: AppLayoutProps) {
    const { state: authState } = useAuth();
    const router = useRouter();
    const theme = useTheme();

    const isDashboard = variant === 'dashboard';
    const isAuth = variant === 'auth';

    // Redirect to login if not authenticated (for dashboard variant)
    useEffect(() => {
        if (isDashboard && authState.isInitialized && !authState.isAuthenticated) {
            router.replace(ROUTES.LOGIN);
        }
    }, [isDashboard, authState.isInitialized, authState.isAuthenticated, router]);

    // Show loading while auth is initializing
    if (isDashboard && !authState.isInitialized) {
        return <LoadingOverlayComponent />;
    }

    // Redirect happens via useEffect, show loading in the meantime
    if (isDashboard && !authState.isAuthenticated) {
        return <LoadingOverlayComponent />;
    }

    // Auth layout (login page)
    if (isAuth) {
        return <div css={authContainer(theme)}>{children}</div>;
    }

    // Dashboard layout
    return (
        <div css={layoutContainer(theme)}>
            {/* Desktop sidebar */}
            {isDashboard && <Sidebar />}

            <div css={mainWrapper(isDashboard, theme)}>
                {/* Header */}
                {showHeader && isDashboard && <Header showSearch={showSearch} />}

                {/* Main content */}
                <main css={contentArea(isDashboard, theme)}>{children}</main>

                {/* Mobile bottom nav */}
                {isDashboard && <MobileNav />}
            </div>
        </div>
    );
});

export default AppLayout;
