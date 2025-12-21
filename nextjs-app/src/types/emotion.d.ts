import '@emotion/react';
import { SerializedStyles } from '@emotion/react';

declare module 'react' {
    interface HTMLAttributes<T> extends DOMAttributes<T> {
        css?: SerializedStyles | SerializedStyles[] | any;
    }
}
