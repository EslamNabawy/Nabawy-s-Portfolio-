/**
 * Long-form content for each project page: the framing, highlights, decisions
 * and architecture layers that do not belong in the portfolio data model.
 *
 * The homepage reads `category` and `timeline` from here too, so a project is
 * described in exactly one place.
 */
export type DetailItem = {
  title: string;
  description: string;
};

export type ArchitectureLayer = {
  name: string;
  items: string[];
};

export type ProjectDetailContent = {
  category: string;
  subtitle: string;
  type: string;
  platform: string;
  timeline: string;
  status: string;
  highlights: DetailItem[];
  decisions: DetailItem[];
  layers: ArchitectureLayer[];
};

export const projectDetails: Record<string, ProjectDetailContent> = {
  'sentinels': {
    category: 'AIOps Platform',
    subtitle: 'Autonomous AIOps platform: detect, diagnose, fix, notify',
    type: 'NTI Graduation Project, team of 6',
    platform: 'Kubernetes, Python, FastAPI, React, Ansible',
    timeline: 'Sep 2026 - Oct 2026',
    status: 'Working platform, level 1 of a 4-level roadmap',
    highlights: [
      {
        title: 'Alert storms become one incident',
        description:
          'Alerts that share a service and a 120-second window are grouped into a single incident. In the demo, 8 noisy alerts collapse into one: checkout is slow for customers.',
      },
      {
        title: 'Two-stage ML detection',
        description:
          'Isolation Forest learns normal behaviour without labelled data and flags the anomaly; a LightGBM classifier then names the fault type, CPU stress, memory leak, network or disk full, with a confidence score.',
      },
      {
        title: 'An agent that cites its evidence',
        description:
          'A ReAct agent over a ChromaDB runbook base queries live Prometheus metrics and Loki logs, then returns a root cause with the evidence behind it. The model runs locally through Ollama, so there is no paid LLM API.',
      },
      {
        title: 'Fixes wait for a human',
        description:
          'In safe mode nothing is applied automatically. An operator approves in the React dashboard, then an Ansible playbook runs. Rejections are recorded too, so every decision has an audit trail.',
      },
      {
        title: 'Scored against ground truth',
        description:
          'Chaos Mesh injects real faults and writes each one to a ground-truth ledger, which is what makes 98% root-cause accuracy and a 0.9999 detection AUC measurable rather than claimed.',
      },
    ],
    decisions: [
      {
        title: 'Testing it by breaking it',
        description:
          'Pod kill, network partition and CPU stress are injected on purpose into Google Online Boutique. Because the fault is known before the platform sees it, detection and diagnosis can be scored instead of demonstrated, and the CI pipeline runs a chaos test before every deploy.',
      },
      {
        title: 'Correlating before investigating',
        description:
          'Deduplication and correlation run ahead of any AI step, so the expensive reasoning is spent once per incident rather than once per alert in a cascade.',
      },
      {
        title: 'Unsupervised first, supervised second',
        description:
          'Labelled failure data is scarce, so detection cannot depend on it. Isolation Forest handles the open-ended question of whether something is wrong; LightGBM answers the narrower question of what kind of fault it is.',
      },
      {
        title: 'Keeping the human in the loop by default',
        description:
          'Autonomous remediation is a switch, not the default. The approval gate makes the platform usable where an unattended ansible-playbook run against production would not be acceptable.',
      },
      {
        title: 'Fail-open alerting',
        description:
          'Notifications are a side effect, not a dependency. If n8n is slow or down, detection, diagnosis and remediation keep running rather than stalling behind the alert.',
      },
      {
        title: 'Running the model locally',
        description:
          'Serving the LLM through Ollama keeps telemetry inside the environment, removes API rate limits from the critical path, and holds inference cost at zero.',
      },
    ],
    layers: [
      { name: 'Workload', items: ['Kubernetes', 'Online Boutique (10 microservices)', 'Chaos Mesh', 'Ground-truth ledger'] },
      { name: 'Telemetry', items: ['OpenTelemetry', 'Prometheus', 'Loki', 'Tempo', 'Grafana'] },
      { name: 'Detection', items: ['Isolation Forest', 'LightGBM classifier', 'Confidence scoring'] },
      { name: 'Correlation', items: ['120 s window', 'Per-service grouping', 'One incident per failure'] },
      { name: 'AI SRE Agent', items: ['ReAct loop', 'ChromaDB runbooks', 'Ollama local LLM', 'Metric and log queries'] },
      { name: 'Action', items: ['React dashboard', 'Operator approval', 'Ansible playbooks', 'Audit trail'] },
      { name: 'Notify', items: ['n8n workflows', 'Telegram', 'Slack', 'Email', 'Fail-open'] },
      { name: 'As Code', items: ['Terraform', 'Docker', 'Jenkins', 'Chaos test in CI'] },
    ],
  },
  fairmatch: {
    category: 'Team Formation Automation',
    subtitle: 'Fair team formation from raw survey responses to published rosters',
    type: 'Automation Workflow',
    platform: 'n8n, JavaScript, Python, Google Sheets API',
    timeline: 'Sep 2026',
    status: 'Published case study',
    highlights: [
      {
        title: 'End-to-end automation',
        description:
          'A single n8n workflow partitions a 24-person cohort into 4 balanced teams of 6, from raw survey responses to published results.',
      },
      {
        title: 'Three-stage pipeline',
        description:
          'Cleaning, solving, and publishing stages handle deduplication, missing-data imputation from peer consensus, rating-scale detection, and rater-consistency auditing.',
      },
      {
        title: 'Verifiable fairness',
        description:
          '20 multi-start solver runs with multi-level local search achieved an inter-team skill gap of 0.19 or less, zero hard-constraint violations, and the required gender distribution.',
      },
    ],
    decisions: [
      {
        title: 'Optimizing lexicographically',
        description:
          'Multi-objective lexicographic optimization keeps fairness criteria in priority order instead of collapsing them into one arbitrary weighted score.',
      },
      {
        title: 'Auditing raters before solving',
        description:
          'Rater-consistency auditing and rating-scale detection catch noisy survey input before it distorts the team assignments.',
      },
      {
        title: 'Cross-checking against a reference',
        description:
          'The workflow output was verified against an independent Python reference implementation, and rosters are published as graded results with a privacy-safe dashboard.',
      },
    ],
    layers: [
      { name: 'Input', items: ['Survey responses', 'Webhooks', 'Google Sheets'] },
      { name: 'Cleaning', items: ['Deduplication', 'Imputation', 'Scale detection', 'Rater audit'] },
      { name: 'Solver', items: ['Lexicographic optimization', '20 multi-start runs', 'Local search'] },
      { name: 'Publishing', items: ['Graded rosters', 'Excel export', 'Live dashboard'] },
    ],
  },
  'devops-library': {
    category: 'DevOps Knowledge Platform',
    subtitle: 'Structured DevOps learning tracks and reference material',
    type: 'Static Site',
    platform: 'GitHub Pages, Linux, Terraform, CI/CD',
    timeline: 'Aug 2026 - Sep 2026',
    status: 'Live',
    highlights: [
      {
        title: 'Technology tracks',
        description:
          'Linux, Terraform, CI/CD, Kubernetes, Docker, and Ansible each get a dedicated track instead of a flat link dump.',
      },
      {
        title: 'Practical resources',
        description:
          'Practical guides, technical documentation, downloadable resources, and learning material are organized for hands-on use and reference.',
      },
      {
        title: 'Built while studying',
        description:
          'Created alongside the NTI AIOps track so study notes become a reusable, extensible knowledge hub.',
      },
    ],
    decisions: [
      {
        title: 'Organizing by track, not by date',
        description:
          'Content is grouped by technology track so the platform stays navigable as new topics are added.',
      },
      {
        title: 'Static hosting for zero operations',
        description:
          'GitHub Pages keeps the site free, versioned, and deployable with the same Git workflow used for CI/CD study.',
      },
      {
        title: 'Extensible by design',
        description:
          'The structure leaves room for new guides and resources without redesigning the site each time.',
      },
    ],
    layers: [
      { name: 'Tracks', items: ['Linux', 'Terraform', 'CI/CD', 'Kubernetes', 'Docker', 'Ansible'] },
      { name: 'Content', items: ['Guides', 'Documentation', 'Downloads'] },
      { name: 'Delivery', items: ['GitHub Pages', 'Git workflow'] },
    ],
  },
  brox: {
    category: 'Operations Platform',
    subtitle: 'Offline-first workspace operations system for Windows',
    type: 'Desktop App',
    platform: 'Windows',
    timeline: 'Current build',
    status: 'Published case study',
    highlights: [
      {
        title: 'Broad operations scope',
        description:
          'Covers check-ins, live sessions, checkout, customers, rooms, desks, kitchen inventory, reservations, analytics, finance, staff, memberships, roles, permissions, audit logs, app health, and local recovery.',
      },
      {
        title: 'Local-first operating model',
        description:
          'The app is designed to keep core desk operations usable without depending on a cloud connection.',
      },
      {
        title: 'Release-oriented engineering',
        description:
          'Includes release packaging, diagnostics, backup and restore, localization, routing, and a documented local schema.',
      },
    ],
    decisions: [
      {
        title: 'Keeping persistence out of the UI',
        description:
          'Repositories and Cubit/Bloc boundaries keep the desktop UI focused on workflows instead of direct storage manipulation.',
      },
      {
        title: 'Making admin workflows recoverable',
        description:
          'Backup, restore, diagnostics, audit logs, and app health are treated as product features, not afterthoughts.',
      },
      {
        title: 'Designing for repeated front-desk use',
        description:
          'Navigation and screens prioritize dense operational scanning, quick actions, and clear role-gated paths.',
      },
    ],
    layers: [
      { name: 'UI Layer', items: ['Flutter Desktop', 'Shared UI primitives', 'Responsive Windows layouts'] },
      { name: 'Navigation', items: ['GoRouter shell routing', 'Role-gated routes', 'Workflow screens'] },
      { name: 'State', items: ['Cubit/Bloc', 'Bounded contexts', 'Repository interfaces'] },
      { name: 'Persistence', items: ['Hive', 'Local datasets', 'Backup / restore', 'Schema version 3'] },
      { name: 'Release', items: ['PowerShell scripts', 'Windows packaging', 'GitHub Actions'] },
    ],
  },
  'rain-p2p-messenger': {
    category: 'Communication App',
    subtitle: 'Private peer messaging across Android and Windows',
    type: 'Mobile / Desktop App',
    platform: 'Android and Windows',
    timeline: 'Current build',
    status: 'Published case study',
    highlights: [
      {
        title: 'Explicit connection states',
        description:
          'Friend requests, accepted peers, blocked users, call states, chat states, and transfer progress are visible instead of hidden behind vague status text.',
      },
      {
        title: 'Focused peer workflows',
        description:
          'Direct chat, one-to-one file transfer, voice calls, and video calls are presented as maintained feature areas.',
      },
      {
        title: 'Separated runtime layers',
        description:
          'UI, local persistence, signaling, session policy, and WebRTC transport are split into focused packages and app layers.',
      },
    ],
    decisions: [
      {
        title: 'Transport and UI separation',
        description:
          'WebRTC data and media behavior stays separate from Flutter screen code so chat, calls, and file transfer can evolve independently.',
      },
      {
        title: 'Local persistence for communication state',
        description:
          'Identity, friends, messages, and files are tracked locally with Drift-backed state instead of making the UI depend on transient runtime state only.',
      },
      {
        title: 'Clear product claims',
        description:
          'The case study avoids claiming push call wakeups, group calls, or app-store packaging that are not part of the maintained scope.',
      },
    ],
    layers: [
      { name: 'App', items: ['Flutter', 'Responsive screens', 'Riverpod controllers'] },
      { name: 'Local Core', items: ['Drift identity', 'Friends', 'Messages', 'Files'] },
      { name: 'Signaling', items: ['Realtime signaling', 'Session policy', 'Connection diagnostics'] },
      { name: 'Peer Transport', items: ['WebRTC data channels', 'Voice calls', 'Video calls'] },
      { name: 'Workspace', items: ['Melos monorepo', 'Android target', 'Windows target'] },
    ],
  },
  'campus-suit': {
    category: 'Campus Product',
    subtitle: 'Campus life app with onboarding, courses, grades, and profile flows',
    type: 'Mobile App',
    platform: 'Cross-platform Flutter',
    timeline: 'Graduation project',
    status: 'Published case study',
    highlights: [
      {
        title: 'Student workflow coverage',
        description:
          'The app connects onboarding, student services, course enrollment, grade tracking, and account/profile flows.',
      },
      {
        title: 'Real app screens',
        description:
          'The case study uses real CampusSuit screenshots for onboarding, dashboard, courses, grades, dialogs, and account screens.',
      },
      {
        title: 'Maintainable mobile structure',
        description:
          'Flutter screens, backend services, API integration, and state management are separated so the app can grow beyond a demo.',
      },
    ],
    decisions: [
      {
        title: 'Designing around campus tasks',
        description:
          'Screens are organized around what a student needs to do: sign in, inspect services, manage courses, check grades, and update their profile.',
      },
      {
        title: 'Keeping live data readable',
        description:
          'The UI presents course and grade data in compact mobile panels instead of burying it behind generic dashboards.',
      },
      {
        title: 'Handling confirmation states',
        description:
          'Enrollment and removal flows include explicit dialogs so destructive or important student actions are not ambiguous.',
      },
    ],
    layers: [
      { name: 'UI', items: ['Flutter screens', 'Onboarding', 'Student dashboard', 'Profile flows'] },
      { name: 'Data', items: ['Backend services', 'REST APIs', 'Live data'] },
      { name: 'State', items: ['BLoC', 'Feature-level state', 'Form state'] },
      { name: 'Product Areas', items: ['Courses', 'Grades', 'Student services', 'Account'] },
    ],
  },
  silvator: {
    category: 'Mood Companion',
    subtitle: 'Mood-aware quote, journal, saved insight, and heatmap experience',
    type: 'Mobile / Desktop App',
    platform: 'Android and Windows',
    timeline: 'Current build',
    status: 'Published case study',
    highlights: [
      {
        title: 'Mood-led product surface',
        description:
          'Silvator organizes the experience around mood selection, quote recommendations, journal capture, saved insights, and reflection.',
      },
      {
        title: 'Responsive app evidence',
        description:
          'Screens show both mobile and Windows desktop layouts, including quote feeds, saved moments, and settings.',
      },
      {
        title: 'Local-only positioning',
        description:
          'The presented product scope emphasizes a local-only mood-aware experience with user-controlled appearance and text settings.',
      },
    ],
    decisions: [
      {
        title: 'Keeping the experience calm',
        description:
          'The UI is built around low-pressure capture, readable quote cards, and simple mood chips instead of heavy dashboard behavior.',
      },
      {
        title: 'Making reflection visible',
        description:
          'Saved insights and the 30-day mood heatmap make repeated entries easier to review without turning the app into a social feed.',
      },
      {
        title: 'Using mood assets carefully',
        description:
          'Mascot mood references support the emotional states without replacing the core journal and quote flows.',
      },
    ],
    layers: [
      { name: 'UI', items: ['Flutter', 'Responsive layouts', 'Mood chips', 'Quote cards'] },
      { name: 'Experience', items: ['Journal prompts', 'Saved insights', 'Mood heatmap'] },
      { name: 'Personalization', items: ['Theme controls', 'Text size', 'Appearance settings'] },
      { name: 'Local Scope', items: ['Local storage', 'Offline-first positioning', 'Mood tagging'] },
    ],
  },
  'ai-workflow-automation': {
    category: 'Omnichannel AI Support',
    subtitle: 'AI-powered customer service automation across WhatsApp and Telegram',
    type: 'Automation Platform',
    platform: 'n8n, Supabase, multi-provider LLMs',
    timeline: 'May 2026 - Jun 2026',
    status: 'Published case study',
    highlights: [
      {
        title: 'Automated response delivery',
        description:
          'Customer requests from WhatsApp and Telegram move through automated response delivery with explicit trigger and output states.',
      },
      {
        title: 'Persistent conversation context',
        description:
          'A Supabase-backed memory layer keeps relevant conversation context available across customer interactions.',
      },
      {
        title: 'Multi-provider routing and safety',
        description:
          'Groq, Gemini, and OpenRouter are routed through inspectable workflow logic, with a safety gate before responses are delivered.',
      },
    ],
    decisions: [
      {
        title: 'Keeping orchestration inspectable',
        description:
          'n8n makes the route from incoming customer request to response visible, helping debug and maintain automation behavior.',
      },
      {
        title: 'Validating before delivery',
        description:
          'A safety gate checks automated responses before they reach WhatsApp or Telegram customers.',
      },
      {
        title: 'Routing across AI providers',
        description:
          'Workflow conditions route requests across Groq, Gemini, and OpenRouter while the memory layer preserves context.',
      },
    ],
    layers: [
      { name: 'Channels', items: ['WhatsApp', 'Telegram', 'Webhook inputs'] },
      { name: 'AI Routing', items: ['Groq', 'Gemini', 'OpenRouter'] },
      { name: 'Memory', items: ['Supabase', 'Conversation context', 'Persistent state'] },
      { name: 'Safety', items: ['Response validation', 'Delivery gates', 'Workflow observability'] },
    ],
  },
  'so-she-picks-ecommerce': {
    category: 'Mobile Commerce',
    subtitle: 'Responsive Flutter ordering app with backend order handling',
    type: 'Mobile App',
    platform: 'Flutter',
    timeline: 'Client-style build',
    status: 'Published case study',
    highlights: [
      {
        title: 'Ordering flow',
        description:
          'The app focuses on browsing, checkout, order state, and repeat customer behavior.',
      },
      {
        title: 'Loyalty behavior',
        description:
          'A loyalty points system supports repeat customers without making the purchase flow complicated.',
      },
      {
        title: 'Backend-connected UI',
        description:
          'Backend order data is used to keep order handling and customer-facing state aligned.',
      },
    ],
    decisions: [
      {
        title: 'Prioritizing simple commerce tasks',
        description:
          'The product surface stays focused on selection, checkout, order handling, and reward behavior.',
      },
      {
        title: 'Keeping rewards understandable',
        description:
          'Loyalty points are included as a clear repeat-customer mechanic rather than a complex marketing system.',
      },
      {
        title: 'Responsive app structure',
        description:
          'Flutter UI screens are organized so browsing and ordering remain usable across different mobile sizes.',
      },
    ],
    layers: [
      { name: 'UI', items: ['Flutter', 'Responsive screens', 'Product browsing'] },
      { name: 'Commerce', items: ['Checkout', 'Order state', 'Loyalty points'] },
      { name: 'Backend', items: ['Backend services', 'Order management', 'Customer data'] },
    ],
  },
};
