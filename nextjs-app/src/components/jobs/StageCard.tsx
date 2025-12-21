import { ReactNode } from 'react';
import { css, useTheme, Theme } from '@emotion/react';

export type StageStatus = 'pending' | 'completed' | 'in_progress' | 'approved' | 'rejected' | 'unknown';

interface StageCardProps {
    title: string;
    icon: ReactNode;
    color: string;
    status?: string;
    children?: ReactNode;
    isCompleted?: boolean;
}

const styles = {
    card: (theme: Theme, isCompleted: boolean, color: string) => css`
    background: #fff;
    border-radius: 12px;
    border: 1px solid ${isCompleted ? `${color}4D` : theme.colors.border};
    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    overflow: hidden;
    margin-bottom: 16px;
    transition: all 0.2s ease;

    &:hover {
      box-shadow: 0 4px 6px rgba(0,0,0,0.08);
    }
  `,
    header: (theme: Theme, color: string) => css`
    padding: 16px;
    display: flex;
    align-items: center;
    border-bottom: 1px solid ${theme.colors.border};
    background-color: ${color}0D; // 5% opacity
  `,
    iconBox: (color: string) => css`
    width: 36px;
    height: 36px;
    border-radius: 8px;
    background-color: ${color}1A; // 10% opacity
    display: flex;
    align-items: center;
    justify-content: center;
    color: ${color};
    margin-right: 12px;
  `,
    title: css`
    font-size: 16px;
    font-weight: 600;
    color: #1f2937;
    flex: 1;
  `,
    status: (statusColor: string) => css`
    padding: 4px 12px;
    border-radius: 12px;
    background-color: ${statusColor}1A;
    color: ${statusColor};
    font-size: 12px;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 4px;
    text-transform: capitalize;
  `,
    content: css`
    padding: 16px;
    background: #fafafa;
  `,
};

export const StageCard = ({ title, icon, color, status, children, isCompleted = false }: StageCardProps) => {
    const theme = useTheme();

    // Determine status color/icon
    // Simple heuristic: if completed usually green, otherwise typically matches stage color or neutral
    const statusColor = isCompleted ? '#10b981' : (status === 'Pending' ? '#f59e0b' : color);

    return (
        <div css={styles.card(theme, isCompleted, color)}>
            <div css={styles.header(theme, color)}>
                <div css={styles.iconBox(color)}>
                    {icon}
                </div>
                <span css={styles.title}>{title}</span>
                {status && (
                    <div css={styles.status(statusColor)}>
                        {isCompleted && <span>✓</span>}
                        {status}
                    </div>
                )}
            </div>
            {children && (
                <div css={styles.content}>
                    {children}
                </div>
            )}
        </div>
    );
};
