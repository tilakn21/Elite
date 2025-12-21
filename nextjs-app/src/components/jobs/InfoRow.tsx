import { css } from '@emotion/react';

interface InfoRowProps {
    label: string;
    value: string | number | null | undefined;
}

const rowStyles = {
    row: css`
    display: flex;
    margin-bottom: 8px;
    font-size: 14px;
    &:last-child {
      margin-bottom: 0;
    }
  `,
    label: css`
    width: 140px;
    font-weight: 500;
    color: #6b7280;
    flex-shrink: 0;
  `,
    value: css`
    color: #111827;
    flex: 1;
    font-weight: 400;
  `
};

export const InfoRow = ({ label, value }: InfoRowProps) => {
    // Don't render if value is empty/null, similar to Flutter implementation
    if (value === null || value === undefined || value === '') return null;

    return (
        <div css={rowStyles.row}>
            <span css={rowStyles.label}>{label}:</span>
            <span css={rowStyles.value}>{value}</span>
        </div>
    );
};
