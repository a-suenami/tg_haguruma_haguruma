import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import * as path from 'path';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [RubyPlugin(), vue()],
  server: {
    allowedHosts: ['vite-dev-server', '.localhost'],
    // Docker環境ではブラウザからはlocalhost:3036でアクセスするため、originを明示的に設定
    origin: process.env.VITE_DEV_SERVER_PUBLIC || 'http://localhost:3036',
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
  css: {
    preprocessorOptions: {
      scss: {
        api: 'modern-compiler',
        includePaths: [
          path.resolve(__dirname, 'app/frontend/styles/gearbox'),
          path.resolve(__dirname, 'app/frontend/styles/gearbox/shared'),
        ],
      },
    },
  },
  define: {
    global: {}, // global is not defined が発生するため
  },
  clearScreen: false
});
