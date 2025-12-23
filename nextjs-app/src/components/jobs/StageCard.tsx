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
  progress?: number; // 0-100
  timeline?: TimelineItem[];
}

export interface TimelineItem {
  label: string;
  timestamp?: string;
  completed: boolean;
  current?: boolean;
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
        background-color: ${color}0D;
    `,
  iconBox: (color: string) => css`
        width: 36px;
        height: 36px;
        border-radius: 8px;
        background-color: ${color}1A;
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
  progressContainer: css`
        padding: 12px 16px;
        background: #f9fafb;
        border-bottom: 1px solid #e5e7eb;
    `,
  progressBar: (color: string, progress: number) => css`
        height: 6px;
        background: #e5e7eb;
        border-radius: 3px;
        overflow: hidden;
        position: relative;
        
        &::after {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: ${progress}%;
            background: ${color};
            border-radius: 3px;
            transition: width 0.3s ease;
        }
    `,
  progressText: css`
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 6px;
        font-size: 12px;
        color: #6b7280;
    `,
  timelineContainer: css`
        padding: 16px;
        background: #fafafa;
        border-bottom: 1px solid #e5e7eb;
    `,
  timelineItem: (completed: boolean, current: boolean, color: string) => css`
        display: flex;
        align-items: flex-start;
        position: relative;
        padding-left: 24px;
        padding-bottom: 16px;
        
        &:last-child {
            padding-bottom: 0;
        }
        
        /* Vertical line */
        &::before {
            content: '';
            position: absolute;
            left: 7px;
            top: 16px;
            bottom: 0;
            width: 2px;
            background: ${completed ? color : '#e5e7eb'};
        }
        
        &:last-child::before {
            display: none;
        }
        
        /* Circle indicator */
        &::after {
            content: '${completed ? '✓' : ''}';
            position: absolute;
            left: 0;
            top: 0;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            background: ${completed ? color : current ? '#fff' : '#e5e7eb'};
            border: 2px solid ${completed ? color : current ? color : '#d1d5db'};
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            color: white;
            ${current && !completed ? `
                box-shadow: 0 0 0 4px ${color}20;
            ` : ''}
        }
    `,
  timelineLabel: (completed: boolean, current: boolean) => css`
        font-size: 13px;
        font-weight: ${current ? 600 : 500};
        color: ${completed ? '#374151' : current ? '#1f2937' : '#9ca3af'};
        line-height: 1.4;
    `,
  timelineTimestamp: css`
        font-size: 11px;
        color: #9ca3af;
        margin-top: 2px;
    `,
  content: css`
        padding: 16px;
        background: #fafafa;
    `,
};

export const StageCard = ({
  title,
  icon,
  color,
  status,
  children,
  isCompleted = false,
  progress,
  timeline,
}: StageCardProps) => {
  const theme = useTheme();
  const statusColor = isCompleted ? '#10b981' : (status === 'Pending' ? '#f59e0b' : color);

  // Calculate progress from timeline if not provided
  const effectiveProgress = progress ?? (timeline
    ? Math.round((timeline.filter(t => t.completed).length / timeline.length) * 100)
    : undefined
  );

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

      {/* Progress Bar */}
      {effectiveProgress !== undefined && (
        <div css={styles.progressContainer}>
          <div css={styles.progressText}>
            <span>Progress</span>
            <span style={{ fontWeight: 600, color }}>{effectiveProgress}%</span>
          </div>
          <div css={styles.progressBar(color, effectiveProgress)} />
        </div>
      )}

      {/* Timeline */}
      {timeline && timeline.length > 0 && (
        <div css={styles.timelineContainer}>
          {timeline.map((item, index) => (
            <div
              key={index}
              css={styles.timelineItem(item.completed, item.current ?? false, color)}
            >
              <div>
                <div css={styles.timelineLabel(item.completed, item.current ?? false)}>
                  {item.label}
                </div>
                {item.timestamp && (
                  <div css={styles.timelineTimestamp}>
                    {item.timestamp}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {children && (
        <div css={styles.content}>
          {children}
        </div>
      )}
    </div>
  );
};
