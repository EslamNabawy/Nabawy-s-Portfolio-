import { defineConfig, envField } from 'astro/config';

export default defineConfig({
  site: 'https://eslamnabawy.github.io',
  base: '/Nabawy-s-Portfolio-/',
  output: 'static',
  env: {
    schema: {
      SUPABASE_URL: envField.string({
        context: 'server',
        access: 'secret',
        optional: true,
      }),
      SUPABASE_ANON_KEY: envField.string({
        context: 'server',
        access: 'secret',
        optional: true,
      }),
    },
  },
});
