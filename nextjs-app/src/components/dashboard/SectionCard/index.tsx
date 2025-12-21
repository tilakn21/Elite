import { memo, type ReactNode } from 'react';
import { useTheme } from '@emotion/react';
import {
    sectionCardContainer,
    sectionHeader,
    sectionIconContainer,
    sectionTitle,
    placeholderContent,
} from './styles';

/**
 * SectionCard Component
 * Reusable dashboard section container with title and optional icon
 */

export interface SectionCardProps {
    title: string;
    icon?: ReactNode;
    iconColor?: string;
    children?: ReactNode;
    placeholder?: string;
}

export const SectionCard = memo(function SectionCard({
    title,
    icon,
    iconColor = '#10B981',
    children,
    placeholder,
}: SectionCardProps) {
    const theme = useTheme();

    return (
        <div css={sectionCardContainer(theme)}>
            <div css={sectionHeader(theme)}>
                {icon && <div css={sectionIconContainer(iconColor)}>{icon}</div>}
                <h2 css={sectionTitle(theme)}>{title}</h2>
            </div>
            {children || (placeholder && <div css={placeholderContent(theme)}>{placeholder}</div>)}
        </div>
    );
});

export default SectionCard;
