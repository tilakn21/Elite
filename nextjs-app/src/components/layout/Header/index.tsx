import { memo } from 'react';
import { useTheme } from '@emotion/react';
import { useAuth } from '@/state';
import { useUI } from '@/state/ui';
import {
    headerContainer,
    menuButton,
    actions,
    userSection,
    userName,
    avatar,
} from './styles';

/**
 * Header Component
 * Matches Flutter's AppBar with notifications and user info
 */

// SVG Icons as components
const MenuIcon = memo(function MenuIcon() {
    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M3 12h18M3 6h18M3 18h18" />
        </svg>
    );
});

export interface HeaderProps {
    showSearch?: boolean; // Kept to avoid breaking interface usage, but unused
}

export const Header = memo(function Header({ }: HeaderProps) {
    const { state: authState } = useAuth();
    const { toggleMobileNav } = useUI();
    const theme = useTheme();

    const user = authState.user;
    const initials = user?.name
        ? user.name
            .split(' ')
            .map((n) => n[0])
            .join('')
            .toUpperCase()
            .slice(0, 2)
        : '?';

    return (
        <header css={headerContainer(theme)}>
            <button css={menuButton(theme)} onClick={toggleMobileNav} aria-label="Toggle menu">
                <MenuIcon />
            </button>

            <div css={actions(theme)}>
                <div css={userSection(theme)}>
                    <span css={userName(theme)}>{user?.name}</span>
                    <div css={avatar(32, theme)}>{initials}</div>
                </div>
            </div>
        </header>
    );
});

export default Header;
