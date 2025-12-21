import { type ButtonHTMLAttributes, type ReactNode, forwardRef, memo } from 'react';
import { useTheme } from '@emotion/react';
import {
    ButtonVariant,
    ButtonSize,
    buttonBase,
    buttonSize,
    buttonFullWidth,
    buttonLoading,
    getButtonVariant,
    spinnerStyles,
} from './styles';

/**
 * Button Component
 * Matches Flutter's ElevatedButton styling with multiple variants
 * Uses memo and forwardRef for performance and ref forwarding
 */

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: ButtonVariant;
    size?: ButtonSize;
    fullWidth?: boolean;
    isLoading?: boolean;
    leftIcon?: ReactNode;
    rightIcon?: ReactNode;
    children: ReactNode;
}

const Spinner = memo(function Spinner() {
    return <span css={spinnerStyles} aria-hidden="true" />;
});

export const Button = memo(
    forwardRef<HTMLButtonElement, ButtonProps>(function Button(
        {
            variant = 'primary',
            size = 'md',
            fullWidth = false,
            isLoading = false,
            leftIcon,
            rightIcon,
            children,
            disabled,
            ...props
        },
        ref
    ) {
        const theme = useTheme();

        return (
            <button
                ref={ref}
                css={[
                    buttonBase(theme),
                    buttonSize[size],
                    getButtonVariant(variant, theme),
                    fullWidth && buttonFullWidth,
                    isLoading && buttonLoading,
                ]}
                disabled={disabled || isLoading}
                {...props}
            >
                {isLoading ? <Spinner /> : leftIcon}
                {children}
                {!isLoading && rightIcon}
            </button>
        );
    })
);

Button.displayName = 'Button';

// Re-export types
export type { ButtonVariant, ButtonSize };

export default Button;
