import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import * as path from 'path';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [RubyPlugin(), vue()],
  server: {
    allowedHosts: ['vite-dev-server', '.localhost'],
    hmr: {
      host: process.env.VITE_SERVER_HMR_HOST || 'localhost',
      clientPort: Number(process.env.VITE_SERVER_HMR_PORT) || 3036,
    },
  },
  resolve: {
    alias: {
      '~': path.resolve(__dirname, './node_modules'),
      '@app': path.resolve(__dirname, 'app/frontend'),
      vue: 'vue/dist/vue.esm-bundler.js',
    },
  },
  define: {
    global: {}, // global is not defined が発生するため
  },
  clearScreen: false
});