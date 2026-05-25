import { defineConfig, envField } from 'astro/config';

export default defineConfig({
  base: '/Nabawy-s-Portfolio-/',
  output: 'static',
  env: {
    schema: {
      SUPABASE_URL: envField.string({
        context: 'server',
        access: 'secret',
      }),
      SUPABASE_ANON_KEY: envField.string({
        context: 'server',
        access: 'secret',
      }),
    },
  },
});
