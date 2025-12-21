import { type InputHTMLAttributes, type ReactNode, forwardRef, memo, useId } from 'react';
import { useTheme } from '@emotion/react';
import {
    InputSize,
    inputContainer,
    inputLabel,
    inputWrapper,
    inputIconWrapper,
    inputIconWrapperThemed,
    inputSize,
    inputBase,
    inputBorder,
    inputLeftIconPadding,
    inputRightIconPadding,
    helperTextStyles,
} from './styles';

/**
 * Input Component
 * Matches Flutter's TextField with label, error, and icon support
 * Uses memo and forwardRef for performance and ref forwarding
 */

export interface InputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'size'> {
    label?: string;
    error?: string;
    helperText?: string;
    leftIcon?: ReactNode;
    rightIcon?: ReactNode;
    size?: InputSize;
    fullWidth?: boolean;
}

export const Input = memo(
    forwardRef<HTMLInputElement, InputProps>(function Input(
        {
            label,
            error,
            helperText,
            leftIcon,
            rightIcon,
            size = 'md',
            fullWidth = true,
            id: providedId,
            ...props
        },
        ref
    ) {
        const theme = useTheme();
        const generatedId = useId();
        const id = providedId || generatedId;
        const hasError = Boolean(error);

        return (
            <div css={inputContainer(fullWidth)}>
                {label && (
                    <label htmlFor={id} css={inputLabel(theme)}>
                        {label}
                    </label>
                )}

                <div css={inputWrapper}>
                    {leftIcon && (
                        <span css={[inputIconWrapper('left'), inputIconWrapperThemed(theme)]}>
                            {leftIcon}
                        </span>
                    )}

                    <input
                        ref={ref}
                        id={id}
                        css={[
                            inputBase(theme),
                            inputSize[size],
                            inputBorder(hasError, theme),
                            leftIcon ? inputLeftIconPadding : undefined,
                            rightIcon ? inputRightIconPadding : undefined,
                        ]}
                        aria-invalid={hasError}
                        aria-describedby={error || helperText ? `${id}-helper` : undefined}
                        {...props}
                    />

                    {rightIcon && (
                        <span css={[inputIconWrapper('right'), inputIconWrapperThemed(theme)]}>
                            {rightIcon}
                        </span>
                    )}
                </div>

                {(error || helperText) && (
                    <span id={`${id}-helper`} css={helperTextStyles(hasError, theme)}>
                        {error || helperText}
                    </span>
                )}
            </div>
        );
    })
);

Input.displayName = 'Input';

// Re-export types
export type { InputSize };

export default Input;
