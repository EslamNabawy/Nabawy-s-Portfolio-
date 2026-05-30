import { createClient } from '@supabase/supabase-js';
import { SUPABASE_ANON_KEY, SUPABASE_URL } from 'astro:env/server';

const url = SUPABASE_URL?.trim();
const anonKey = SUPABASE_ANON_KEY?.trim();

export const supabase =
  url && anonKey && anonKey !== 'replace-with-your-publishable-or-anon-key'
    ? createClient(url, anonKey, {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
          detectSessionInUrl: false,
        },
      })
    : null;
