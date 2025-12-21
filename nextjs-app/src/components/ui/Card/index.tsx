import { type HTMLAttributes, type ReactNode, memo } from 'react';
import { useTheme } from '@emotion/react';
import {
    CardVariant,
    CardPadding,
    cardBase,
    cardPadding,
    getCardVariant,
    cardHoverable,
    cardClickable,
    cardHeader,
    cardTitle,
    cardContent,
    cardFooter,
} from './styles';

/**
 * Card Component
 * Matches Flutter's Card widget with variants and hover effects
 * Uses React.memo to prevent unnecessary re-renders
 */

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
    variant?: CardVariant;
    padding?: CardPadding;
    hoverable?: boolean;
    clickable?: boolean;
    children: ReactNode;
}

export const Card = memo(function Card({
    variant = 'outlined',
    padding = 'md',
    hoverable = false,
    clickable = false,
    children,
    ...props
}: CardProps) {
    const theme = useTheme();

    return (
        <div
            css={[
                cardBase(theme),
                cardPadding[padding],
                getCardVariant(variant, theme),
                hoverable && cardHoverable(theme),
                clickable && cardClickable,
            ]}
            {...props}
        >
            {children}
        </div>
    );
});

// Card sub-components with memo
export const CardHeader = memo(function CardHeader({
    children,
    ...props
}: HTMLAttributes<HTMLDivElement> & { children: ReactNode }) {
    const theme = useTheme();
    return (
        <div css={cardHeader(theme)} {...props}>
            {children}
        </div>
    );
});

export const CardTitle = memo(function CardTitle({
    children,
    ...props
}: HTMLAttributes<HTMLHeadingElement> & { children: ReactNode }) {
    const theme = useTheme();
    return (
        <h3 css={cardTitle(theme)} {...props}>
            {children}
        </h3>
    );
});

export const CardContent = memo(function CardContent({
    children,
    ...props
}: HTMLAttributes<HTMLDivElement> & { children: ReactNode }) {
    return (
        <div css={cardContent} {...props}>
            {children}
        </div>
    );
});

export const CardFooter = memo(function CardFooter({
    children,
    ...props
}: HTMLAttributes<HTMLDivElement> & { children: ReactNode }) {
    const theme = useTheme();
    return (
        <div css={cardFooter(theme)} {...props}>
            {children}
        </div>
    );
});

// Re-export types
export type { CardVariant, CardPadding };

export default Card;
