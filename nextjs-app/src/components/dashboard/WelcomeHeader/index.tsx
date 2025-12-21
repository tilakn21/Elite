import { memo, type ReactNode } from 'react';
import { useTheme } from '@emotion/react';
import {
    welcomeContainer,
    welcomeContent,
    welcomeIconContainer,
    welcomeTextContainer,
    welcomeTitle,
    welcomeSubtitle,
} from './styles';

/**
 * WelcomeHeader Component
 * Dashboard welcome banner with icon, title, and subtitle
 */

export interface WelcomeHeaderProps {
    icon?: ReactNode;
    title: string;
    subtitle?: string;
}

// Default admin icon
const AdminIcon = memo(function AdminIcon() {
    return (
        <svg
            width="28"
            height="28"
            viewBox="0 0 24 24"
            fill="none"
            stroke="white"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
        >
            <path d="M12 4.354a4 4 0 1 1 0 5.292M15 21H3v-1a6 6 0 0 1 12 0v1zm0 0h6v-1a6 6 0 0 0-9-5.197M13 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0z" />
        </svg>
    );
});

export const WelcomeHeader = memo(function WelcomeHeader({
    icon,
    title,
    subtitle,
}: WelcomeHeaderProps) {
    const theme = useTheme();

    return (
        <div css={welcomeContainer(theme)}>
            <div css={welcomeContent(theme)}>
                <div css={welcomeIconContainer}>
                    {icon || <AdminIcon />}
                </div>
                <div css={welcomeTextContainer}>
                    <h1 css={welcomeTitle}>{title}</h1>
                    {subtitle && <p css={welcomeSubtitle}>{subtitle}</p>}
                </div>
            </div>
        </div>
    );
});

export default WelcomeHeader;
