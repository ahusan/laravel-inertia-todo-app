import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

const fileRegex = /.html?special$/;
export default defineConfig({
    plugins: [
        laravel({
            input: 'resources/js/app.js',
            refresh: true,
        }),
        vue({
            template: {
                transformAssetUrls: {
                    base: '/',
                    includeAbsolute: false,
                },
            },
            server: {
                host: 'localhost',
                hmr: {
                    clientPort: 5173,
                    host: '0.0.0.0',
                },
                watch: {
                    usePolling: true
                }
            },
            base: '/'
            

        }),
        
    ],
});
