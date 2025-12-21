import { memo } from 'react';
import { useTheme } from '@emotion/react';
import { statCardContainer, statLabel, statValue, statChange } from './styles';

/**
 * StatCard Component
 * Displays a summary statistic with label, value, and change indicator
 */

export interface StatCardProps {
    label: string;
    value: string | number;
    change?: string;
    positive?: boolean;
}

export const StatCard = memo(function StatCard({
    label,
    value,
    change,
    positive = true,
}: StatCardProps) {
    const theme = useTheme();

    return (
        <div css={statCardContainer(theme)}>
            <span css={statLabel(theme)}>{label}</span>
            <span css={statValue(theme)}>{value}</span>
            {change && (
                <span css={statChange(positive, theme)}>
                    {positive ? '↑' : '↓'} {change} from last month
                </span>
            )}
        </div>
    );
});

export default StatCard;
