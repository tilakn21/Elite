/**
 * Select Component
 * Styled select input matching the Input component
 */

import styled from '@emotion/styled';
import { forwardRef } from 'react';

export type SelectSize = 'sm' | 'md' | 'lg';

export interface SelectOption {
    value: string | number;
    label: string;
}

export interface SelectProps extends Omit<React.SelectHTMLAttributes<HTMLSelectElement>, 'size'> {
    label?: string;
    error?: string;
    fullWidth?: boolean;
    size?: SelectSize;
    options: SelectOption[];
    placeholder?: string;
}

const Wrapper = styled.div<{ fullWidth?: boolean }>`
  display: flex;
  flex-direction: column;
  gap: 6px;
  width: ${({ fullWidth }) => (fullWidth ? '100%' : 'auto')};
`;

const Label = styled.label`
  font-size: 14px;
  font-weight: 500;
  color: #374151;
`;

const StyledSelectWrapper = styled.div`
  position: relative;
  display: flex;
  align-items: center;
`;

const StyledSelect = styled.select<{ hasError?: boolean; inputSize: SelectSize }>`
  width: 100%;
  appearance: none;
  background-color: #fff;
  border: 1px solid ${({ hasError }) => (hasError ? '#ef4444' : '#d1d5db')};
  border-radius: 8px;
  color: #1f2937;
  font-family: inherit;
  font-size: ${({ inputSize }) => (inputSize === 'sm' ? '13px' : inputSize === 'lg' ? '16px' : '14px')};
  padding: ${({ inputSize }) =>
        inputSize === 'sm' ? '6px 32px 6px 12px' : inputSize === 'lg' ? '12px 36px 12px 16px' : '10px 36px 10px 14px'};
  transition: all 0.2s;
  cursor: pointer;

  &:focus {
    outline: none;
    border-color: #6366f1;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
  }

  &:disabled {
    background-color: #f3f4f6;
    cursor: not-allowed;
    color: #9ca3af;
  }
`;

const ArrowIcon = styled.svg`
  position: absolute;
  right: 12px;
  pointer-events: none;
  color: #6b7280;
`;

const ErrorMessage = styled.span`
  font-size: 12px;
  color: #ef4444;
  margin-top: 2px;
`;

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
    ({ label, error, fullWidth = false, size = 'md', options, placeholder, className, ...props }, ref) => {
        return (
            <Wrapper fullWidth={fullWidth} className={className}>
                {label && <Label>{label}</Label>}
                <StyledSelectWrapper>
                    <StyledSelect ref={ref} hasError={!!error} inputSize={size} {...props}>
                        {placeholder && (
                            <option value="" disabled>
                                {placeholder}
                            </option>
                        )}
                        {options.map((option) => (
                            <option key={option.value} value={option.value}>
                                {option.label}
                            </option>
                        ))}
                    </StyledSelect>
                    <ArrowIcon width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <path d="M6 9l6 6 6-6" />
                    </ArrowIcon>
                </StyledSelectWrapper>
                {error && <ErrorMessage>{error}</ErrorMessage>}
            </Wrapper>
        );
    }
);

Select.displayName = 'Select';

export default Select;
