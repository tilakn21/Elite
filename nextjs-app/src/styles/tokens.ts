/**
 * Design Tokens - Extracted from Flutter AppTheme
 * These values match the Flutter app's visual design
 */

// Color palette
export const colors = {
    // Primary colors
    primary: '#1E2E3D',
    accent: '#4ECDC4',
    secondary: '#4ECDC4',

    // Background colors
    background: '#F5F7FA',
    card: '#FFFFFF',
    surface: '#FFFFFF',

    // Text colors
    textPrimary: '#1E2E3D',
    textSecondary: '#6B7280',
    textMuted: '#9CA3AF',
    textOnPrimary: '#FFFFFF',
    textOnAccent: '#FFFFFF',

    // Border colors
    divider: '#E5E7EB',
    border: '#E5E7EB',
    borderFocus: '#4ECDC4',

    // Status colors
    error: '#EF4444',
    success: '#10B981',
    warning: '#F59E0B',
    info: '#3B82F6',

    // Job status colors (from Flutter)
    inProgress: '#AB68FF',
    pending: '#FF6868',
    approved: '#10B981',
    queued: '#FF6868',
    pendingApproval: '#AB68FF',
    designCompleted: '#10B981',

    // Login page specific
    loginBackground: '#F7F6FF',
    loginCard: '#F9F7FA',
    loginButton: '#E6007A',
    loginButtonHover: '#C70066',
    loginText: '#1B2330',
    loginSubtext: '#7B7B93',
} as const;

// Typography
export const typography = {
    fontFamily: "'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",

    sizes: {
        displayLarge: '24px',
        displayMedium: '20px',
        displaySmall: '18px',
        headlineMedium: '16px',
        headlineSmall: '14px',
        titleLarge: '16px',
        titleMedium: '14px',
        bodyLarge: '14px',
        bodyMedium: '14px',
        bodySmall: '12px',
        caption: '11px',
    },

    lineHeights: {
        tight: 1.2,
        normal: 1.5,
        relaxed: 1.75,
    },

    weights: {
        regular: 400,
        medium: 500,
        semiBold: 600,
        bold: 700,
    },

    letterSpacing: {
        tight: '-0.02em',
        normal: '0',
        wide: '0.02em',
        wider: '0.05em',
    },
} as const;

// Spacing scale (4px base)
export const spacing = {
    0: '0',
    1: '4px',
    2: '8px',
    3: '12px',
    4: '16px',
    5: '20px',
    6: '24px',
    8: '32px',
    10: '40px',
    12: '48px',
    16: '64px',
    20: '80px',
} as const;

// Border radius
export const radii = {
    none: '0',
    sm: '4px',
    md: '6px',
    lg: '8px',
    xl: '12px',
    '2xl': '16px',
    '3xl': '24px',
    full: '9999px',
} as const;

// Shadows (matching Flutter elevations)
export const shadows = {
    none: 'none',
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
    xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
    card: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
    cardHover: '0 4px 12px 0 rgba(0, 0, 0, 0.15)',
} as const;

// Transitions
export const transitions = {
    fast: '150ms ease-in-out',
    normal: '200ms ease-in-out',
    slow: '300ms ease-in-out',
} as const;

// Breakpoints
export const breakpoints = {
    xs: '375px',
    sm: '600px',
    md: '900px',
    lg: '1100px',
    xl: '1440px',
} as const;

// Z-index scale
export const zIndices = {
    base: 0,
    dropdown: 100,
    sticky: 200,
    modal: 300,
    popover: 400,
    toast: 500,
    tooltip: 600,
} as const;

// Layout dimensions
export const layout = {
    sidebarWidth: '188px',
    sidebarCollapsedWidth: '64px',
    headerHeight: '64px',
    maxContentWidth: '1440px',
    containerPadding: '16px',
} as const;
