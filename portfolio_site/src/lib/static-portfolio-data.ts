import type { Experiment, PageSection, Project, SiteConfig, Skill } from './types';

type StaticPortfolioData = {
  config: SiteConfig;
  projects: Project[];
  skills: Skill[];
  experiments: Experiment[];
  sections: PageSection[];
};

const updatedAt = '2026-05-30T00:00:00.000Z';

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
    headline: 'Software Engineer building reliable apps and practical automation.',
    bio:
      'Computer Science graduate who turns product ideas into usable software with clean interfaces, solid integrations, and fast AI-assisted delivery.',
    resume_url: 'resume.pdf',
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
    skill('mobile-frontend', 'Mobile And Frontend', [
      'Flutter',
      'Dart',
      'BLoC',
      'MVC',
      'Responsive UI',
      'React.js familiarity',
      'HTML',
      'CSS',
      'Figma',
    ], 10),
    skill('backend-apis', 'Backend, APIs, And Data', [
      'Auth Flows',
      'Realtime Data Modeling',
      'File Upload Flows',
      'REST API Integration',
      'SDK Usage',
      'Supabase basics',
      'SQL / NoSQL concepts',
    ], 20),
    skill('ai-automation', 'AI And Automation', [
      'n8n Workflow Automation',
      'OpenAI API Integration',
      'Claude API Integration',
      'AI Agent Pipelines',
      'Webhook Orchestration',
      'AI-Assisted App Creation',
      'Prompted Debugging',
    ], 30),
    skill('engineering-core', 'Engineering Core', [
      'OOP',
      'Design Patterns',
      'Data Structures And Algorithms',
      'Git / GitHub',
      'Docker familiarity',
      'AWS familiarity',
      'CI/CD concepts',
      'Technical Documentation',
    ], 40),
  ],
  projects: [
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
      featured: true,
      display_order: 10,
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
      display_order: 20,
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
      display_order: 30,
    }),
    project({
      id: 'ai-workflow-automation',
      title: 'AI Workflow Automation - n8n Pipelines',
      slug: 'ai-workflow-automation',
      description:
        'Personal automation work connecting LLM APIs, webhooks, and external services with n8n. The workflows automate data processing, smart notifications, AI-generated content flows, conditional routing, and error-aware execution.',
      short_description:
        'n8n automation pipelines that connect LLM APIs, webhooks, and external services into reliable AI workflows.',
      role: 'AI Automation Builder',
      impact: 'Converted manual multi-step work into repeatable workflows with visible control points and failure handling.',
      architecture_notes:
        'Workflows are modeled as event-driven pipelines with webhook triggers, LLM calls, conditional branches, retries, and explicit notification paths.',
      case_study_markdown:
        'Focused on practical automation: fast iteration, clear inputs/outputs, and workflows that can be inspected instead of running as hidden magic.',
      tech_stack: ['n8n', 'OpenAI API', 'Claude API', 'Webhooks', 'Automation'],
      project_images: [
        projectImage('ai-workflow-primary', 'ai-workflow-automation', 'project-assets/ai-workflow-automation.svg', 'AI automation pipeline mockup'),
      ],
      github_url: null,
      live_url: null,
      image_url: 'project-assets/ai-workflow-automation.svg',
      featured: false,
      display_order: 40,
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
      display_order: 50,
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
      'freelance-software-developer',
      'Freelance Software Developer',
      'Experience',
      'Built cross-platform Flutter apps, integrated REST APIs and backend services, and shipped client feedback cycles with Git from November 2022 to present.',
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
      'Led Flutter workshops, mentored beginners, and helped coordinate NextGen and Google I/O extended events with the GDSC AEA team.',
      30,
    ),
    experience(
      'icpc-core-team',
      'ICPC Core Team Member',
      'Competitive Programming',
      'Organized problem-solving contests, mentored new members, and spent three years around algorithmic problem solving under pressure.',
      40,
    ),
  ],
  sections: [],
};
