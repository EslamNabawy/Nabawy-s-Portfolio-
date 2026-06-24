import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.86.0';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const GITHUB_TOKEN = Deno.env.get('GITHUB_TOKEN') ?? '';
const GITHUB_REPO = Deno.env.get('GITHUB_REPO') ?? '';
const GITHUB_WORKFLOW = Deno.env.get('GITHUB_WORKFLOW') ?? 'deploy.yml';
const GITHUB_BRANCH = Deno.env.get('GITHUB_BRANCH') ?? 'main';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const adminSupabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405);
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : '';
  if (!token) {
    return json({ error: 'Missing authorization token' }, 401);
  }

  const { data: userResult, error: userError } = await supabase.auth.getUser(token);
  if (userError || !userResult.user) {
    return json({ error: 'Invalid session' }, 401);
  }

  const { data: adminRow, error: adminError } = await adminSupabase
    .from('admin_users')
    .select('user_id')
    .eq('user_id', userResult.user.id)
    .maybeSingle();

  if (adminError || !adminRow) {
    return json({ error: 'Not authorized to publish' }, 403);
  }

  const { data: logRow, error: logError } = await adminSupabase
    .from('publish_log')
    .insert({
      status: 'pending',
      message: 'Publish requested from dashboard.',
      triggered_by: userResult.user.id,
    })
    .select('id')
    .single();

  if (logError || !logRow) {
    return json({ error: `Failed to create publish log: ${logError?.message ?? 'unknown error'}` }, 500);
  }

  const payload = {
    owner: GITHUB_REPO.split('/')[0] ?? '',
    repo: GITHUB_REPO.split('/')[1] ?? '',
    workflow_id: GITHUB_WORKFLOW,
    ref: GITHUB_BRANCH,
  };

  if (!payload.owner || !payload.repo || !GITHUB_TOKEN) {
    await adminSupabase
      .from('publish_log')
      .update({
        status: 'failed',
        message: 'Publish service is not configured.',
      })
      .eq('id', logRow.id);
    return json({ error: 'Publish service is not configured' }, 500);
  }

  const response = await fetch(
    `https://api.github.com/repos/${payload.owner}/${payload.repo}/actions/workflows/${encodeURIComponent(payload.workflow_id)}/dispatches`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${GITHUB_TOKEN}`,
        Accept: 'application/vnd.github+json',
        'Content-Type': 'application/json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
      body: JSON.stringify({ ref: payload.ref }),
    },
  );

  if (!response.ok) {
    const text = await response.text();
    await adminSupabase
      .from('publish_log')
      .update({
        status: 'failed',
        message: `GitHub dispatch failed: ${text}`,
      })
      .eq('id', logRow.id);
    return json({ error: `GitHub dispatch failed: ${text}` }, 502);
  }

  await adminSupabase
    .from('publish_log')
    .update({
      status: 'success',
      message: 'GitHub Pages rebuild triggered.',
      workflow_run_url: `https://github.com/${payload.owner}/${payload.repo}/actions/workflows/${payload.workflow_id}`,
    })
    .eq('id', logRow.id);

  return json({
    ok: true,
    message: 'GitHub Pages rebuild triggered.',
    workflow: payload.workflow_id,
    ref: payload.ref,
  });
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
