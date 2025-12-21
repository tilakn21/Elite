# Elite Signboard - Code Standards & Development Guidelines

## Overview
This document establishes industry-standard coding practices for the Elite Next.js application to ensure clean, scalable, and maintainable production code.

---

## 1. Project Structure

```
src/
├── components/           # Reusable UI components
│   ├── layout/          # Layout components (AppLayout, Sidebar, Header)
│   ├── ui/              # Generic UI (Button, Input, Card, Modal)
│   ├── dashboard/       # Dashboard-specific components
│   └── jobs/            # Job-related components
├── pages/               # Next.js pages (routing)
│   ├── salesperson/
│   │   ├── index.tsx    # Page component only
│   │   └── styles.ts    # Page-specific styles
│   └── ...
├── services/            # API/Supabase service layer
├── state/               # Global state (Auth, UI contexts)
├── styles/              # Global styles, theme, tokens
├── types/               # TypeScript type definitions
├── hooks/               # Custom React hooks
└── utils/               # Utility functions
```

---

## 2. File Organization Rules

### Components
Each component folder contains:
```
ComponentName/
├── index.tsx           # Component logic & JSX
├── styles.ts           # Emotion CSS styles
└── types.ts            # (optional) Component-specific types
```

### Pages
Each page follows the same pattern:
```
pages/dashboard-name/
├── index.tsx           # Page component
├── styles.ts           # Page styles
├── sub-page.tsx        # Nested page
└── sub-page.styles.ts  # Nested page styles
```

**Naming Convention:**
- Styles file for `index.tsx` → `styles.ts`
- Styles file for `profile.tsx` → `profile.styles.ts`

---

## 3. CSS/Styling Standards

### Use Emotion with Theme
```typescript
// styles.ts
import { css, Theme } from '@emotion/react';

export const container = (theme: Theme) => css`
    padding: ${theme.spacing[6]};
    background: ${theme.colors.surface};
    border-radius: ${theme.radii.lg};
`;

// Static styles (no theme dependency)
export const flexRow = css`
    display: flex;
    gap: 16px;
`;
```

### Style Naming
- Use **camelCase** for style function names
- Be descriptive: `jobCardHeader`, not `header`
- Group related styles: `button`, `buttonPrimary`, `buttonDisabled`

### Responsive Design
- Mobile-first approach
- Use theme breakpoints: `theme.breakpoints.sm/md/lg/xl`
- Always test at 320px, 768px, 1024px, 1440px

```typescript
export const grid = (theme: Theme) => css`
    display: grid;
    grid-template-columns: 1fr;
    
    @media (min-width: ${theme.breakpoints.md}) {
        grid-template-columns: repeat(2, 1fr);
    }
    
    @media (min-width: ${theme.breakpoints.lg}) {
        grid-template-columns: repeat(3, 1fr);
    }
`;
```

---

## 4. TypeScript Standards

### Strict Type Safety
- Enable `strict` mode in `tsconfig.json`
- No `any` types without explicit justification
- Define interfaces for all data shapes

### Type File Organization
```typescript
// types/salesperson.ts
export interface SiteVisitItem {
    jobCode: string;
    customerName: string;
    status: 'pending' | 'submitted' | 'completed';
}

// Use type imports
import type { SiteVisitItem } from '@/types/salesperson';
```

### Props Interface Naming
```typescript
// ComponentNameProps
interface JobCardProps {
    job: SiteVisitItem;
    onClick?: () => void;
}
```

---

## 5. Component Standards

### Functional Components Only
```typescript
export function JobCard({ job, onClick }: JobCardProps) {
    // ...
}
```

### Hook Usage Order
1. External hooks (useRouter, useTheme)
2. Auth/State hooks (useAuth, useUI)
3. Local state (useState)
4. Effects (useEffect)
5. Callbacks (useCallback, useMemo)

### Memoization
- Use `memo()` for expensive render components
- Use `useMemo()` for computed values
- Use `useCallback()` for event handlers passed to children

---

## 6. Service Layer Standards

### Service Structure
```typescript
// services/salesperson.service.ts
export const salespersonService = {
    async getAssignedJobs(id: string): Promise<Job[]> {
        // Implementation
    },
    
    async submitJob(data: JobData): Promise<Result> {
        // Implementation
    }
};
```

### Error Handling
```typescript
async function fetchData(): Promise<Data[]> {
    try {
        const { data, error } = await supabase.from('table').select('*');
        if (error) {
            console.error('Context:', error);
            return [];
        }
        return data ?? [];
    } catch (error) {
        console.error('Unexpected error:', error);
        return [];
    }
}
```

---

## 7. Import Organization

```typescript
// 1. React/Next.js
import { useState, useEffect } from 'react';
import Head from 'next/head';
import { useRouter } from 'next/router';

// 2. Third-party libraries
import { css, useTheme } from '@emotion/react';

// 3. Internal: Layout/Components
import { AppLayout } from '@/components/layout';
import { Button, Card } from '@/components/ui';

// 4. Internal: State/Hooks
import { useAuth } from '@/state';

// 5. Internal: Services
import { salespersonService } from '@/services/salesperson.service';

// 6. Internal: Types
import type { SiteVisitItem } from '@/types/salesperson';

// 7. Local: Styles
import * as styles from './styles';
// OR
import { container, header } from './profile.styles';
```

---

## 8. Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Files (components) | PascalCase folder | `JobCard/index.tsx` |
| Files (pages) | kebab-case | `new-job.tsx` |
| Files (styles) | lowercase + .styles | `profile.styles.ts` |
| Variables | camelCase | `jobCount` |
| Constants | UPPER_SNAKE | `MAX_JOBS` |
| Types/Interfaces | PascalCase | `JobRequest` |
| Enums | PascalCase | `JobStatus.Pending` |

---

## 9. Git Commit Standards

```
<type>(<scope>): <subject>

Types: feat, fix, refactor, style, docs, test, chore
Scope: salesperson, receptionist, admin, ui, services

Examples:
feat(salesperson): add job details submission form
fix(calendar): resolve mobile responsiveness issues
refactor(services): extract common query patterns
```

---

## 10. Code Quality Checklist

Before committing:
- [ ] No TypeScript errors (`npx tsc --noEmit`)
- [ ] No ESLint warnings
- [ ] Styles extracted to separate file
- [ ] Responsive design tested
- [ ] Loading/Error states handled
- [ ] Console.log statements removed
- [ ] Meaningful variable names
- [ ] No hardcoded colors (use theme)
