import { defineConfig } from 'vite';

export default defineConfig({
    server: {
        host: true, // Enables listening on all local IPs (0.0.0.0)
        port: 5173  // Default port
    },
    base: './'
});
