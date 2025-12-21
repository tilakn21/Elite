'use client';

import { useState, useEffect } from 'react';

/**
 * Breakpoint values in pixels (matching Flutter's responsive behavior)
 */
export const BREAKPOINT_VALUES = {
    xs: 375,
    sm: 600,
    md: 900,
    lg: 1100,
    xl: 1440,
} as const;

type Breakpoint = keyof typeof BREAKPOINT_VALUES;

/**
 * Hook to check if a media query matches
 * SSR-safe: returns false on server, hydrates correctly on client
 */
export function useMediaQuery(query: string): boolean {
    const [matches, setMatches] = useState(false);

    useEffect(() => {
        // Check if window is available (client-side only)
        if (typeof window === 'undefined') return;

        const mediaQuery = window.matchMedia(query);
        setMatches(mediaQuery.matches);

        const handler = (event: MediaQueryListEvent) => {
            setMatches(event.matches);
        };

        // Modern browsers
        mediaQuery.addEventListener('change', handler);

        return () => {
            mediaQuery.removeEventListener('change', handler);
        };
    }, [query]);

    return matches;
}

/**
 * Hook to check if screen is at or above a breakpoint
 * Example: useBreakpoint('md') returns true for screens >= 900px
 */
export function useBreakpoint(breakpoint: Breakpoint): boolean {
    const value = BREAKPOINT_VALUES[breakpoint];
    return useMediaQuery(`(min-width: ${value}px)`);
}

/**
 * Hook to check if screen is below a breakpoint
 * Example: useBreakpointDown('md') returns true for screens < 900px
 */
export function useBreakpointDown(breakpoint: Breakpoint): boolean {
    const value = BREAKPOINT_VALUES[breakpoint];
    return useMediaQuery(`(max-width: ${value - 1}px)`);
}

/**
 * Hook to check if screen is between two breakpoints
 * Example: useBreakpointBetween('sm', 'lg') returns true for 600px <= screen < 1100px
 */
export function useBreakpointBetween(lower: Breakpoint, upper: Breakpoint): boolean {
    const lowerValue = BREAKPOINT_VALUES[lower];
    const upperValue = BREAKPOINT_VALUES[upper];
    return useMediaQuery(`(min-width: ${lowerValue}px) and (max-width: ${upperValue - 1}px)`);
}

/**
 * Responsive breakpoint helpers (matching Flutter's behavior)
 */
export function useResponsive() {
    const isMobile = useBreakpointDown('sm'); // < 600px (Flutter: isMobile)
    const isTablet = useBreakpointBetween('sm', 'lg'); // 600px - 1099px
    const isDesktop = useBreakpoint('lg'); // >= 1100px (Flutter: isDesktop)

    return {
        isMobile,
        isTablet,
        isDesktop,
        // Convenience helpers
        isMobileOrTablet: isMobile || isTablet,
        isTabletOrDesktop: isTablet || isDesktop,
    };
}

/**
 * Hook to get current window dimensions
 * SSR-safe with default values
 */
export function useWindowSize() {
    const [size, setSize] = useState({
        width: 0,
        height: 0,
    });

    useEffect(() => {
        if (typeof window === 'undefined') return;

        const handleResize = () => {
            setSize({
                width: window.innerWidth,
                height: window.innerHeight,
            });
        };

        // Set initial size
        handleResize();

        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
    }, []);

    return size;
}

/**
 * Hook to check user's motion preference
 */
export function usePrefersReducedMotion(): boolean {
    return useMediaQuery('(prefers-reduced-motion: reduce)');
}

/**
 * Hook to check user's color scheme preference
 */
export function usePrefersDarkMode(): boolean {
    return useMediaQuery('(prefers-color-scheme: dark)');
}

export default useMediaQuery;
