import type { Experiment, PageSection, Project, SiteConfig, Skill } from './types';
import fairmatchAlgorithm from '../content/fairmatch-algorithm.md?raw';

type StaticPortfolioData = {
  config: SiteConfig;
  projects: Project[];
  skills: Skill[];
  experiments: Experiment[];
  sections: PageSection[];
};

const updatedAt = '2026-09-30T00:00:00.000Z';

const projectImage = (
  id: string,
  projectId: string,
  imageUrl: string,
  altText: string,
  displayOrder = 0,
) => ({
  id,
  project_id: projectId,
  image_url: imageUrl,
  alt_text: altText,
  display_order: displayOrder,
  created_at: updatedAt,
  updated_at: updatedAt,
});

const campusSuitScreenAlts = [
  'CampusSuit splash screen',
  'CampusSuit onboarding welcome screen',
  'CampusSuit course enrollment onboarding screen',
  'CampusSuit grades tracking onboarding screen',
  'CampusSuit login screen',
  'CampusSuit loading state screen',
  'CampusSuit student services dashboard screen',
  'CampusSuit selected course details screen',
  'CampusSuit selected courses summary screen',
  'CampusSuit available courses enrollment screen',
  'CampusSuit remove course confirmation dialog',
  'CampusSuit add course confirmation dialog',
  'CampusSuit add course warning dialog',
  'CampusSuit account screen',
  'CampusSuit edit account screen',
  'CampusSuit grades screen',
];

const broxDesktopScreenAlts = [
  'Brox desktop live desk screen',
  'Brox desktop live desk cart overlay',
  'Brox desktop checkout confirmation',
  'Brox desktop reservations list',
  'Brox desktop reservation form dialog',
  'Brox desktop rooms setup screen',
  'Brox desktop meeting hub screen',
  'Brox desktop inventory list screen',
  'Brox desktop room map screen',
  'Brox desktop finance and staff screen',
  'Brox desktop dashboard overview',
];

const broxMobileScreenAlts = [
  'Brox mobile navigation drawer',
  'Brox mobile dashboard screen',
  'Brox mobile analytics screen',
  'Brox mobile finance and staff screen',
  'Brox mobile reservations calendar screen',
  'Brox mobile reservation form screen',
  'Brox mobile settings screen',
];

const rainMobileScreenAlts = [
  'Rain mobile splash screen',
  'Rain mobile friends list screen',
  'Rain mobile peer notification request dialog',
  'Rain mobile accepted connection request state',
  'Rain Android notification shade for peer connection request',
  'Rain mobile direct chat with completed file transfer',
  'Rain mobile voice call ended dialog over chat',
  'Rain mobile video call ringing screen',
  'Rain mobile video call ended dialog',
  'Rain mobile peer search screen',
  'Rain mobile settings and audio controls screen',
];

const rainDesktopScreenAlts = [
  'Rain Windows desktop splash screen',
  'Rain Windows desktop friends and connection state screen',
  'Rain Windows desktop settings screen',
];

const silvatorMobileScreenAlts = [
  'Silvator mobile sanctuary home with mood chips and quote recommendations',
  'Silvator mobile quote feed filtered by mood state',
  'Silvator mobile safe-space journal entry screen',
  'Silvator mobile saved insights and mood heatmap screen',
  'Silvator mobile profile and appearance settings screen',
];

const silvatorDesktopScreenAlts = [
  'Silvator Windows desktop calm quote feed screen',
  'Silvator Windows desktop love quote feed screen',
  'Silvator Windows desktop saved quotes and insights screen',
];

const project = (input: Omit<Project, 'is_published' | 'created_at' | 'updated_at'>): Project => ({
  ...input,
  is_published: true,
  created_at: updatedAt,
  updated_at: updatedAt,
});

const skill = (id: string, category: string, items: string[], displayOrder: number): Skill => ({
  id,
  category,
  items,
  display_order: displayOrder,
  is_published: true,
  updated_at: updatedAt,
});

const experience = (
  id: string,
  title: string,
  category: string,
  summary: string,
  displayOrder: number,
): Experiment => ({
  id,
  title,
  slug: id,
  status: 'active',
  category,
  summary,
  writeup_markdown: null,
  media_url: null,
  github_url: null,
  live_url: null,
  display_order: displayOrder,
  is_published: true,
  created_at: updatedAt,
  updated_at: updatedAt,
});

export const staticPortfolioData: StaticPortfolioData = {
  config: {
    id: 'global',
    name: 'Eslam Tarek Nabawy',
    headline: 'Software Engineer | DevOps, AIOps & Automation',
    bio:
      'Software engineer going deeper into DevOps and AIOps, hands-on with Linux, Docker, Kubernetes, CI/CD, observability, and automation. Builds operations workflows with Python, n8n, Ollama, and multi-provider LLMs, aimed at root cause analysis and anomaly-driven operations. Currently completing the 420-hour NTI AIOps Engineer Track while building an AIOps capstone that injects Kubernetes faults, collects the resulting telemetry, and scores AI-generated root cause analysis against known ground truth. End-to-end delivery experience across cross-platform apps, automation systems, and SaaS products.',
    resume_url: 'https://drive.google.com/drive/folders/1-THpoKa7tuM2fNNUTPfNsdvtAQuUz1cL?usp=sharing',
    github_url: 'https://github.com/EslamNabawy',
    linkedin_url: 'https://www.linkedin.com/in/eslam-tarek-nabawy/',
    instagram_url: 'https://www.instagram.com/eslamtareknabawy/',
    phone: '+201015683693',
    email: 'eslamtarek.dev@gmail.com',
    design_variant: 'signal_studio',
    theme_json: {
      accentColor: 'signal',
      backgroundMode: 'clean',
      surfaceStyle: 'elevated',
      radius: 'standard',
      borderWeight: 'thin',
      density: 'standard',
      motionIntensity: 'reduced',
      heroTreatment: 'studio',
      heroLayout: 'split',
      sectionOrder: 'recruiter_first',
      projectCardStyle: 'visual',
      showFeaturedProjectPanel: true,
    },
    updated_at: updatedAt,
  },
  skills: [
    skill('devops-infra', 'DevOps & Infrastructure', ['Linux', 'Docker', 'Kubernetes', 'WSL2', 'Terraform', 'Git', 'GitHub Actions', 'CI/CD', 'GitHub CLI'], 10),
    skill('observability-aiops', 'Observability & AIOps', ['Prometheus', 'Grafana', 'Alerting', 'Alert Correlation', 'Root Cause Analysis', 'Anomaly Detection', 'Chaos Engineering'], 20),
    skill('ai-automation', 'AI & Automation', ['Python', 'LLM Integration', 'Ollama', 'LangGraph', 'n8n', 'Webhooks', 'OpenAI', 'Claude', 'Groq', 'Gemini', 'OpenRouter'], 30),
    skill('backend-data', 'Backend & Data', ['PostgreSQL', 'Supabase Edge Functions', 'Firebase', 'REST APIs', 'SQL', 'SQLite', 'Drift', 'Hive', 'NoSQL', 'Google Sheets API', 'Data Modeling'], 40),
    skill('software-engineering', 'Software Engineering', ['JavaScript', 'Dart', 'Flutter', 'Software Architecture', 'Clean Code', 'OOP', 'Design Patterns', 'Data Structures & Algorithms', 'Melos Monorepo'], 50),
  ],
  projects: [
    project({
      id: 'sentinels',
      title: 'Sentinels',
      slug: 'sentinels',
      description:
        'Autonomous AIOps platform built as a six-person NTI graduation project. It watches a 10-microservice e-commerce system running on Kubernetes, detects abnormal behaviour with machine learning, groups alert storms into a single incident, and uses a retrieval-augmented AI SRE agent to explain the root cause with evidence from live metrics and logs. A proposed fix runs as an Ansible playbook only after an operator approves it, every decision is audited, and the team is notified on Telegram, Slack or email through n8n. The platform is tested the honest way: Chaos Mesh breaks the system on purpose, and every injected fault is logged as ground truth to score detection and diagnosis.',
      short_description:
        'An AIOps platform that spots failures in a Kubernetes system, finds the root cause with ML and an AI SRE agent, and fixes them after one approval.',
      role: 'ML Lead: anomaly detection and fault classification',
      impact:
        'On a chaos-tested environment: 98% root-cause accuracy, 100% fault-type classification, 0.9999 anomaly-detection AUC, runbook matches under 10 ms, and alert storms collapsed from 8 alerts into 1 incident, all at $0 in LLM API cost because the model runs locally.',
      architecture_notes:
        'Four stages, left to right in seconds. Workload: Google Online Boutique (10 microservices) on Kubernetes with Chaos Mesh injecting pod kill, network partition and CPU stress. Telemetry: OpenTelemetry ships metrics to Prometheus, logs to Loki, traces to Tempo, visualised in Grafana. Intelligence: a FastAPI core runs Isolation Forest anomaly detection, a LightGBM fault classifier, 120-second alert correlation and a ReAct RAG agent over a ChromaDB runbook base with a local LLM through Ollama. Action: a React dashboard takes the operator approval, Ansible applies the fix, and n8n fans the incident out to Telegram, Slack and email. Redis backs cache and state, and Terraform, Docker and Jenkins define the whole thing as code.',
      case_study_markdown: [
        'Production systems fail at 3 AM. One broken service fires hundreds of alerts, engineers dig through dashboards by hand, and the fix happens under pressure with no guardrails. **Sentinels** is an AIOps platform built to close that loop: it spots the failure, explains why it happened, fixes it safely with one approval, and keeps the team informed.',
        '**How it works.** Sentinels watches a 10-microservice shop running on Kubernetes. OpenTelemetry streams metrics, logs and traces into Prometheus, Loki and Tempo. A two-stage ML pipeline flags anomalies with Isolation Forest and names the fault with LightGBM. Related alerts on the same service inside a 120-second window are grouped into one incident, and an AI SRE agent, a local LLM with a runbook knowledge base, investigates with live metrics and logs before proposing a fix. Nothing touches production until an operator approves; then Ansible applies the fix and n8n notifies the team on Telegram, Slack or email.',
        '**Detection runs in two stages.** Isolation Forest is unsupervised, so it learns what normal looks like without labelled data and flags the outlier. A LightGBM classifier then names the fault type, CPU stress, memory leak, network or disk full, with a confidence score, which is what lets the agent start from a hypothesis instead of a blank page.',
        '**The agent shows its work.** A ReAct loop of think, act, observe and verify searches runbooks and past incidents in a ChromaDB knowledge base, queries live Prometheus metrics and Loki logs, and returns a root cause together with the evidence behind it and a proposed fix. The model is served locally through Ollama, so no telemetry leaves the environment and there is no paid LLM API.',
        '**Built to be trusted.** Every fix waits for approval, and approvals and rejections are both audited. The alerting bridge is fail-open: if n8n is slow or down, detection, diagnosis and remediation keep running. The platform is tested by breaking it, with Chaos Mesh faults written to a ground-truth ledger, and the CI pipeline runs a chaos test before every deploy, so a release only ships if Sentinels catches the injected fault.',
        '**Ask Sentinels.** A read-only chat assistant sits on every dashboard page. Anyone on the team can ask in plain language what is broken, why it failed, or whether a fix is waiting, and the answers come from the incidents, telemetry and documentation the platform already holds, with its sources cited.',
        '**Results.** Measured against the Chaos Mesh ground-truth ledger on the Online Boutique test environment: 98% root-cause accuracy, 100% fault-type classification accuracy, an anomaly-detection AUC of 0.9999, runbook matches in under 10 ms, and $0 in API cost. The qualitative version is one outage with two endings: without Sentinels, customers find the problem first and the team sees alerts everywhere with no clear cause; with Sentinels, the same failure becomes one incident with a clear cause and a one-click fix, and customers never notice.',
        '**My role.** I led the ML pipeline: the Isolation Forest anomaly detection that decides whether something is wrong without labelled data, the LightGBM classifier that names the fault type, and the evaluation of both against the chaos ground truth, which is where the 98% root-cause accuracy and the 0.9999 detection AUC come from.',
        '**What is next.** Today sits at level 1 of a four-level roadmap. Level 2 is smarter detection with LSTM and Transformer models, dependency-graph root cause and failure prediction. Level 3 is safer autonomy: a digital twin that tests every fix, self-healing for low-risk issues, and multi-agent agreement on root cause. Level 4 is zero-touch operations across AWS, Azure and GCP with incidents ranked by business cost.',
      ].join('\n\n'),
      tech_stack: ['Python', 'FastAPI', 'React', 'Kubernetes', 'Docker', 'scikit-learn', 'LightGBM', 'Ollama', 'ChromaDB', 'OpenTelemetry', 'Prometheus', 'Grafana', 'Loki', 'Tempo', 'Chaos Mesh', 'Terraform', 'Ansible', 'Jenkins', 'n8n', 'Redis'],
      project_images: [
        projectImage('sentinels-demo-01', 'sentinels', 'project-assets/sentinels/demo/demo-01-dashboard-overview.png', 'Sentinels dashboard showing service health for the microservices', 10),
        projectImage('sentinels-demo-02', 'sentinels', 'project-assets/sentinels/demo/demo-02-fault-injection.png', 'Fault injection console injecting network latency', 20),
        projectImage('sentinels-demo-03', 'sentinels', 'project-assets/sentinels/demo/demo-03-approval-gate.png', 'Incident waiting for operator approval with a proposed Ansible playbook', 30),
        projectImage('sentinels-demo-04', 'sentinels', 'project-assets/sentinels/demo/demo-04-root-cause-and-ansible.png', 'Root cause analysis and the approved Ansible playbook running', 40),
        projectImage('sentinels-demo-05', 'sentinels', 'project-assets/sentinels/demo/demo-05-alert-email.png', 'Critical anomaly alert email sent through n8n', 50),
        projectImage('sentinels-demo-06', 'sentinels', 'project-assets/sentinels/demo/demo-06-resolved-and-assistant.png', 'Resolved incident with the Sentinels assistant summarising system health', 60),
        projectImage('sentinels-slide-04', 'sentinels', 'project-assets/sentinels/slides/04-architecture.png', 'Sentinels architecture from Kubernetes workload through OpenTelemetry telemetry and the FastAPI brain to dashboard, Ansible and n8n actions', 70),
        projectImage('sentinels-slide-06', 'sentinels', 'project-assets/sentinels/slides/06-ml-detection.png', 'Two-stage ML: Isolation Forest flags the anomaly and LightGBM names the fault type', 80),
        projectImage('sentinels-slide-07', 'sentinels', 'project-assets/sentinels/slides/07-alert-correlation.png', 'Alert correlation turning eight alerts into one incident', 90),
        projectImage('sentinels-slide-08', 'sentinels', 'project-assets/sentinels/slides/08-ai-sre-agent.png', 'AI SRE agent investigating with runbooks, a local LLM, Prometheus metrics and Loki logs', 100),
        projectImage('sentinels-slide-09', 'sentinels', 'project-assets/sentinels/slides/09-safe-remediation.png', 'Human-approved remediation flow with Ansible', 110),
        projectImage('sentinels-slide-10', 'sentinels', 'project-assets/sentinels/slides/10-ask-sentinels.png', 'Ask Sentinels chat assistant answering a question about a live incident', 120),
        projectImage('sentinels-slide-11', 'sentinels', 'project-assets/sentinels/slides/11-instant-alerts.png', 'n8n routing incident events to Telegram, Slack and email', 130),
        projectImage('sentinels-slide-05', 'sentinels', 'project-assets/sentinels/slides/05-chaos-engineering.png', 'Chaos engineering slide with injected faults logged as ground truth', 140),
        projectImage('sentinels-slide-12', 'sentinels', 'project-assets/sentinels/slides/12-devops-pipeline.png', 'DevOps pipeline: commit, build, test, chaos test, deploy', 150),
        projectImage('sentinels-slide-02', 'sentinels', 'project-assets/sentinels/slides/02-problem.png', 'Slide explaining why downtime is expensive, noisy and slow to fix', 160),
        projectImage('sentinels-slide-03', 'sentinels', 'project-assets/sentinels/slides/03-solution-loop.png', 'The Sentinels closed loop: detect, diagnose, fix, notify', 170),
        projectImage('sentinels-slide-13', 'sentinels', 'project-assets/sentinels/slides/13-impact.png', 'Comparison of the same outage without and with Sentinels', 180),
        projectImage('sentinels-slide-14', 'sentinels', 'project-assets/sentinels/slides/14-future-work.png', 'Sentinels roadmap in four levels', 190),
        projectImage('sentinels-slide-15', 'sentinels', 'project-assets/sentinels/slides/15-team-thank-you.png', 'Team Sentinels: six team members on the closing slide', 200),
        projectImage('sentinels-slide-01', 'sentinels', 'project-assets/sentinels/slides/01-cover.png', 'Sentinels title slide: an autonomous AIOps platform that detects, diagnoses and fixes production failures', 210),
      ],
      github_url: 'https://github.com/Moha-sys/NTI_Project_Sentinelas',
      live_url: null,
      image_url: 'project-assets/sentinels/demo/demo-01-dashboard-overview.png',
      featured: true,
      display_order: 5,
    }),
    project({
      id: 'fairmatch',
      title: 'FairMatch',
      slug: 'fairmatch',
      description:
        'Automated fair team formation system built as an n8n workflow that partitions a 24-person cohort into 4 balanced teams of 6 using multi-objective lexicographic optimization, from raw survey responses to published results. A 3-stage pipeline handles cleaning, solving, and publishing with deduplication, missing-data imputation from peer consensus, rating-scale detection, and rater-consistency auditing.',
      short_description:
        'n8n pipeline that forms 4 balanced teams of 6 from survey data with measurable fairness guarantees.',
      role: 'Automation Engineer',
      impact: 'Achieved an inter-team skill gap of 0.19 or less, zero hard-constraint violations, and the required gender distribution across 20 multi-start solver runs.',
      architecture_notes:
        'Three stages: clean, solve, publish. The solver runs 20 multi-start iterations with multi-level local search, then publishes graded rosters (0-100 fairness score, A-F per team) to Google Sheets and Excel plus a privacy-safe live dashboard, verified against a Python reference implementation.',
      case_study_markdown: [
        'Built entirely as an automated workflow: raw survey responses go in, graded and privacy-safe rosters come out, with solver output cross-checked against an independent Python implementation.',
        fairmatchAlgorithm.trim(),
      ].join('\n\n'),
      tech_stack: ['n8n', 'JavaScript', 'Python', 'Google Sheets API', 'Webhooks', 'HTML', 'CSS'],
      project_images: [
        projectImage(
          'fairmatch-screen-01',
          'fairmatch',
          'project-assets/fairmatch/01-solver-workflow.png',
          'FairMatch n8n solver workflow: read raw responses, clean and normalize, run solver engine, write team output',
          10,
        ),
        projectImage(
          'fairmatch-screen-02',
          'fairmatch',
          'project-assets/fairmatch/02-publish-workflow.png',
          'FairMatch n8n publishing workflow: webhook reads team sheets, builds HTML dashboard, responds with live page',
          20,
        ),
        projectImage(
          'fairmatch-screen-03',
          'fairmatch',
          'project-assets/fairmatch/03-results-dashboard.png',
          'FairMatch live results dashboard header with 24 members, 4 teams, finalized September 25, 2026',
          30,
        ),
        projectImage(
          'fairmatch-screen-04',
          'fairmatch',
          'project-assets/fairmatch/04-team-cards.png',
          'FairMatch dashboard team cards showing average skill, compatibility, and skill spread per team',
          40,
        ),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/fairmatch/cover.png',
      featured: true,
      display_order: 10,
    }),
    project({
      id: 'campus-suit',
      title: 'CampusSuit',
      slug: 'campus-suit',
      description:
        'Graduation project built as a cross-platform campus life app. The app covers onboarding, campus events, profile management, live data, backend workflows, and API integrations.',
      short_description:
        'Flutter campus activity app focused on onboarding, events, profile workflows, and live data.',
      role: 'Flutter Developer / Graduation Project Engineer',
      impact: 'Turned campus activity workflows into a usable cross-platform product experience.',
      architecture_notes:
        'Built with Flutter, backend services, REST API integration, and maintainable state management patterns so features could grow without turning the UI layer into backend glue.',
      case_study_markdown:
        'Implemented core mobile flows, real-time data handling, and structured feature screens for campus users.',
      tech_stack: ['Flutter', 'Backend Services', 'REST APIs', 'BLoC', 'Cross-Platform UI'],
      project_images: [
        projectImage('campus-suit-primary', 'campus-suit', 'project-assets/campus-suit/showcase.jpg', 'CampusSuit screenshot-based mobile app mockup'),
        ...campusSuitScreenAlts.map((altText, index) =>
          projectImage(
            `campus-suit-screen-${String(index + 1).padStart(2, '0')}`,
            'campus-suit',
            `project-assets/campus-suit/screens/${String(index + 1).padStart(2, '0')}.jpg`,
            altText,
            (index + 1) * 10,
          ),
        ),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/campus-suit/showcase.jpg',
      featured: false,
      display_order: 40,
    }),
    project({
      id: 'rain-p2p-messenger',
      title: 'Rain P2P Messenger',
      slug: 'rain-p2p-messenger',
      description:
        'Private peer-to-peer chat app for Android and Windows. Rain focuses on accepted friends, direct chat, visible connection state, one-to-one file transfer, voice calls, and video calls. The system separates Flutter UI, Riverpod state, runtime controllers, local Drift persistence, realtime signaling, and WebRTC data/media transport.',
      short_description:
        'Private Android/Windows peer chat app with WebRTC messaging, file transfer, voice/video calls, realtime signaling, and local persistence.',
      role: 'Flutter / WebRTC Engineer',
      impact: 'Built a focused private-communication product surface with explicit friend, route, call, file, and recovery states.',
      architecture_notes:
        'Monorepo split: apps/rain for the Flutter app, rain_core for Drift identity/friends/messages/files, protocol_brain for realtime signaling and session policy, peer_core for WebRTC data/media primitives, and backend rules plus cleanup functions.',
      case_study_markdown:
        'Current maintained targets are Android phones and Windows desktop. Working feature areas include username sign-in, friend search/requests/blocking, peer chat over WebRTC data channels, connection diagnostics, one-to-one file transfer, and one-to-one voice/video calls. Push call wakeups, group calls, and app-store packaging are not claimed.',
      tech_stack: ['Flutter', 'Riverpod', 'WebRTC', 'Realtime Signaling', 'Drift', 'Melos'],
      project_images: [
        projectImage('rain-primary', 'rain-p2p-messenger', 'project-assets/rain/showcase.jpg', 'Rain screenshot-based Android and Windows mockup'),
        ...rainMobileScreenAlts.map((altText, index) =>
          projectImage(
            `rain-mobile-screen-${String(index + 1).padStart(2, '0')}`,
            'rain-p2p-messenger',
            `project-assets/rain/mobile/${String(index + 1).padStart(2, '0')}.jpg`,
            altText,
            (index + 1) * 10,
          ),
        ),
        ...rainDesktopScreenAlts.map((altText, index) =>
          projectImage(
            `rain-desktop-screen-${String(index + 1).padStart(2, '0')}`,
            'rain-p2p-messenger',
            `project-assets/rain/desktop/${String(index + 1).padStart(2, '0')}.jpg`,
            altText,
            200 + (index + 1) * 10,
          ),
        ),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/rain/showcase.jpg',
      featured: true,
      display_order: 30,
    }),
    project({
      id: 'brox',
      title: 'Brox',
      slug: 'brox',
      description:
        'Offline-first Flutter desktop workspace operations app for coworking/business-space owners and front-desk teams. It manages check-ins, live sessions, checkout, customers, rooms, desks, kitchen inventory, reservations, analytics, finance/staff, memberships, data export/restore, roles, permissions, audit log, app health, and local release packaging.',
      short_description:
        'Offline-first Flutter desktop operations system for coworking spaces, front desk workflows, memberships, inventory, analytics, and local data recovery.',
      role: 'Flutter Desktop Engineer',
      impact: 'Built a broad local-first operations console with business rules, persistent repositories, role-gated workflows, and release documentation.',
      architecture_notes:
        'Uses Flutter desktop UI, GoRouter shell routing, Cubit/Bloc state management, Hive local persistence through JSON-backed repositories, EasyLocalization for English/Arabic, shared UI primitives/design tokens, PowerShell release scripts, and GitHub Actions. The current operating model is local/offline; cloud sync is a future option, not a current claim.',
      case_study_markdown:
        'Verified current context reports 531 Dart files under lib/src, 98 Dart test files, 520 widgets, local schema version 3, and local datasets for customers, sessions, reservations, rooms, consumables, finance, memberships, roles, and audit logs.',
      tech_stack: ['Flutter Desktop', 'Cubit/Bloc', 'Hive', 'GoRouter', 'EasyLocalization', 'Windows'],
      project_images: [
        projectImage('brox-primary', 'brox', 'project-assets/brox/showcase.jpg', 'Brox screenshot-based desktop and mobile mockup'),
        ...broxDesktopScreenAlts.map((altText, index) =>
          projectImage(
            `brox-desktop-screen-${String(index + 1).padStart(2, '0')}`,
            'brox',
            `project-assets/brox/desktop/${String(index + 1).padStart(2, '0')}.jpg`,
            altText,
            (index + 1) * 10,
          ),
        ),
        ...broxMobileScreenAlts.map((altText, index) =>
          projectImage(
            `brox-mobile-screen-${String(index + 1).padStart(2, '0')}`,
            'brox',
            `project-assets/brox/mobile/${String(index + 1).padStart(2, '0')}.jpg`,
            altText,
            200 + (index + 1) * 10,
          ),
        ),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/brox/showcase.jpg',
      featured: true,
      display_order: 20,
    }),
    project({
      id: 'ai-workflow-automation',
      title: 'Omnichannel AI Support',
      slug: 'ai-workflow-automation',
      description:
        'AI-powered customer service automation platform built with n8n. It automates context-aware response delivery across WhatsApp and Telegram while routing requests across multiple AI providers.',
      short_description:
        'AI customer service automation for WhatsApp and Telegram with persistent context, multi-provider routing, and safety gates.',
      role: 'AI Automation Engineer',
      impact: 'Turned customer-service requests into inspectable automated conversations with controlled delivery and persistent context.',
      architecture_notes:
        'Built an event-driven n8n system with WhatsApp and Telegram inputs, Supabase-backed conversation memory, multi-provider routing across Groq, Gemini, and OpenRouter, and validation gates before response delivery.',
      case_study_markdown:
        'The platform combines automated response delivery with persistent context and safety validation so AI output is checked before it reaches a customer.',
      tech_stack: ['n8n', 'Supabase', 'Groq', 'Gemini', 'OpenRouter', 'WhatsApp', 'Telegram'],
      project_images: [
        projectImage('ai-workflow-primary', 'ai-workflow-automation', 'project-assets/ai-workflow-automation.svg', 'AI automation pipeline mockup'),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/ai-workflow-automation.svg',
      featured: true,
      display_order: 15,
    }),
    project({
      id: 'devops-library',
      title: 'DevOps Library',
      slug: 'devops-library',
      description:
        'Structured DevOps learning and resource platform covering Linux, Terraform, CI/CD, Kubernetes, Docker, and Ansible. Practical guides, technical documentation, downloadable resources, and learning materials are organized into dedicated technology tracks so the site works as an extensible knowledge hub for hands-on DevOps learning and reference.',
      short_description:
        'GitHub Pages knowledge hub for hands-on DevOps learning: Linux, Terraform, CI/CD, Kubernetes, Docker, and Ansible tracks.',
      role: 'DevOps Content Engineer',
      impact: 'Published a structured DevOps reference that turns study notes into reusable, organized technology tracks.',
      architecture_notes:
        'Static GitHub Pages site organized into technology tracks with practical guides, documentation, and downloadable resources, designed to keep extending as new DevOps topics are covered.',
      case_study_markdown:
        'Built while studying for the NTI AIOps track: each technology gets its own track with guides, references, and resources instead of a flat list of links.',
      tech_stack: ['GitHub Pages', 'Linux', 'Terraform', 'CI/CD', 'Kubernetes', 'Docker', 'Ansible'],
      project_images: [
        projectImage('devops-library-cover', 'devops-library', 'project-assets/devops-library/cover.png', 'DevOps By Nabawy cover with mobile track cards and library screens'),
        projectImage('devops-library-primary', 'devops-library', 'project-assets/devops-library.svg', 'DevOps Library learning platform tracks mockup', 5),
        projectImage(
          'devops-library-screen-01',
          'devops-library',
          'project-assets/devbynabawy/01-library-track-cards.png',
          'DevOps Library home with track cards for CI/CD, Terraform, and Kubernetes',
          10,
        ),
        projectImage(
          'devops-library-screen-02',
          'devops-library',
          'project-assets/devbynabawy/02-library-tracks-scroll.png',
          'DevOps Library track list scrolled with more tracks',
          20,
        ),
        projectImage(
          'devops-library-screen-03',
          'devops-library',
          'project-assets/devbynabawy/03-library-mobile-nav.png',
          'DevOps Library on mobile with bottom navigation',
          30,
        ),
      ],
      github_url: null,
      live_url: 'https://eslamnabawy.github.io/DevOps-By-Nabawy',
      image_url: 'project-assets/devops-library/cover.png',
      featured: false,
      display_order: 50,
    }),
    project({
      id: 'so-she-picks-ecommerce',
      title: 'So She Picks: E-Commerce',
      slug: 'so-she-picks-ecommerce',
      description:
        'Flutter e-commerce ordering app with responsive UI, backend order management, and a loyalty points system for repeat customers.',
      short_description:
        'Responsive Flutter e-commerce interface with backend order handling and loyalty points.',
      role: 'Flutter Developer',
      impact: 'Delivered ordering and loyalty flows for a mobile commerce experience in under three months.',
      architecture_notes:
        'Used backend order data and focused UI state to keep browsing, checkout, and loyalty behavior understandable.',
      case_study_markdown:
        'Built the customer-facing ordering flow, order state, and rewards behavior around simple mobile interactions.',
      tech_stack: ['Flutter', 'Backend Services', 'Responsive UI', 'E-Commerce', 'Order Management'],
      project_images: [
        projectImage('so-she-picks-primary', 'so-she-picks-ecommerce', 'project-assets/so-she-picks.svg', 'So She Picks ordering app mockup'),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/so-she-picks.svg',
      featured: false,
      display_order: 70,
    }),
    project({
      id: 'silvator',
      title: 'Silvator',
      slug: 'silvator',
      description:
        'Mood companion app interface for Android and Windows. Silvator focuses on a sanctuary-style home screen, mood-tagged quote recommendations, safe-space journaling prompts, saved insights, a 30-day mood heatmap, appearance controls, and a local-only mood-aware product experience.',
      short_description:
        'Mood companion app with quote recommendations, safe-space journaling, saved insights, mood heatmap, and Android/Windows responsive screens.',
      role: 'Flutter Product UI Engineer / AI-Assisted App Builder',
      impact: 'Turned mood states into a usable product surface with clear capture, reflection, saved-content, and personalization flows.',
      architecture_notes:
        'Screenshot-backed scope shows responsive mobile and desktop UI, mood chips, quote filtering, journal prompts, saved-state views, local app settings, and mascot-driven mood assets. The product is presented as offline-first and local-only in the app settings screen.',
      case_study_markdown:
        'Visible feature set includes sanctuary mood selection, quote cards with actions, safe-space journal capture, saved moments, 30-day mood heatmap, text-size controls, theme controls, and mood-engine weights for author and tag matching.',
      tech_stack: ['Flutter', 'Dart', 'Responsive UI', 'Local Storage', 'Mood Tagging', 'AI-Assisted UI'],
      project_images: [
        projectImage('silvator-primary', 'silvator', 'project-assets/silvator/showcase.jpg', 'Silvator screenshot-based Android and Windows mood app mockup'),
        ...silvatorMobileScreenAlts.map((altText, index) =>
          projectImage(
            `silvator-mobile-screen-${String(index + 1).padStart(2, '0')}`,
            'silvator',
            `project-assets/silvator/mobile/${String(index + 1).padStart(2, '0')}.jpg`,
            altText,
            (index + 1) * 10,
          ),
        ),
        ...silvatorDesktopScreenAlts.map((altText, index) =>
          projectImage(
            `silvator-desktop-screen-${String(index + 1).padStart(2, '0')}`,
            'silvator',
            `project-assets/silvator/desktop/${String(index + 1).padStart(2, '0')}.jpg`,
            altText,
            120 + (index + 1) * 10,
          ),
        ),
        projectImage('silvator-mood-original', 'silvator', 'project-assets/silvator/original.webp', 'Silvator base mascot mood reference', 210),
        projectImage('silvator-mood-love', 'silvator', 'project-assets/silvator/LOVE.webp', 'Silvator love mood mascot reference', 220),
        projectImage('silvator-mood-stress', 'silvator', 'project-assets/silvator/STRESS.webp', 'Silvator stress mood mascot reference', 230),
        projectImage('silvator-mood-sadness', 'silvator', 'project-assets/silvator/SAD.webp', 'Silvator sadness mood mascot reference', 240),
        projectImage('silvator-mood-happiness', 'silvator', 'project-assets/silvator/happy.webp', 'Silvator happiness mood mascot reference', 250),
        projectImage('silvator-mood-loneliness', 'silvator', 'project-assets/silvator/LONLEY.webp', 'Silvator loneliness mood mascot reference', 260),
        projectImage('silvator-mood-confidence', 'silvator', 'project-assets/silvator/CONFEDINCE.webp', 'Silvator confidence mood mascot reference', 270),
        projectImage('silvator-mood-anxiety', 'silvator', 'project-assets/silvator/anxiety.webp', 'Silvator anxiety mood mascot reference', 280),
        projectImage('silvator-mood-anger', 'silvator', 'project-assets/silvator/ANGRY.webp', 'Silvator anger mood mascot reference', 290),
        projectImage('silvator-mood-fear', 'silvator', 'project-assets/silvator/FEAR.webp', 'Silvator fear mood mascot reference', 300),
        projectImage('silvator-mood-boredom', 'silvator', 'project-assets/silvator/BORED.webp', 'Silvator boredom mood mascot reference', 310),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/silvator/showcase.jpg',
      featured: false,
      display_order: 60,
    }),
  ],
  experiments: [
    experience(
      'nti-aiops-track',
      'AIOps Engineer Track (I021) — NTI',
      'Certification',
      '420-hour National Telecommunication Institute AIOps Engineer Track covering AIOps platforms, Kubernetes and cloud observability, ML-based anomaly detection, SRE practices, communication, leadership, presentation, and project management. In progress since July 2026, with a capstone that injects Kubernetes faults, collects telemetry, and evaluates AI-generated root cause analysis against known ground truth.',
      5,
    ),
    experience(
      'freelance-software-developer',
      'Freelance Software Developer',
      'Experience',
      'Built and shipped cross-platform Flutter applications, integrated REST APIs and backend services, and delivered end-to-end client feedback cycles with Git from November 2022 to present.',
      10,
    ),
    experience(
      'programming-instructor',
      'Programming Instructor',
      'Teaching',
      'Designed lessons for programming fundamentals, OOP, algorithms, data structures, and practical software development for school and private students.',
      20,
    ),
    experience(
      'gdsc-flutter-head',
      'Flutter Head - Google Developer Student Club',
      'Leadership',
      'Led the Flutter team from October 2022 to October 2023, organized Flutter sessions, mentored beginners, and supported NextGen and Google I/O Extended events.',
      30,
    ),
    experience(
      'icpc-core-team',
      'ICPC Core Team Member',
      'Competitive Programming',
      'Supported university-level programming contests from June 2020 to October 2023 and helped participants build data-structures, algorithms, and competitive-programming skills.',
      40,
    ),
  ],
  sections: [],
};
