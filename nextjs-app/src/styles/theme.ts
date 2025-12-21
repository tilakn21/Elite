import { Theme } from '@emotion/react';
import {
    colors,
    typography,
    spacing,
    radii,
    shadows,
    transitions,
    breakpoints,
    zIndices,
    layout,
} from './tokens';

/**
 * Emotion Theme Object
 * Typed theme that matches Flutter's AppTheme
 */
export const theme: Theme = {
    colors,
    typography,
    spacing,
    radii,
    shadows,
    transitions,
    breakpoints,
    zIndices,
    layout,
};

// Type declaration for Emotion's theme
declare module '@emotion/react' {
    export interface Theme {
        colors: typeof colors;
        typography: typeof typography;
        spacing: typeof spacing;
        radii: typeof radii;
        shadows: typeof shadows;
        transitions: typeof transitions;
        breakpoints: typeof breakpoints;
        zIndices: typeof zIndices;
        layout: typeof layout;
    }
}

export default theme;
