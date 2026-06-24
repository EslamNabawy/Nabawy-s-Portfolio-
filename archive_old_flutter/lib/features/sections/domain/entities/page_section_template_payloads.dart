const featuredCaseStudyContent = <String, Object?>{
  'schemaVersion': 2,
  'blocks': [
    {
      'type': 'cardGrid',
      'items': [
        {
          'label': 'Problem',
          'title': 'Constraint',
          'copy': 'What made this hard.',
        },
        {
          'label': 'System',
          'title': 'Architecture',
          'copy': 'How it was built.',
        },
        {'label': 'Result', 'title': 'Outcome', 'copy': 'What improved.'},
      ],
    },
    {
      'type': 'ctaRow',
      'actions': [
        {'label': 'Review Systems', 'url': '#projects'},
      ],
    },
  ],
};

const metricContent = <String, Object?>{
  'schemaVersion': 2,
  'blocks': [
    {
      'type': 'metricStrip',
      'items': [
        {
          'label': 'SSG',
          'title': 'Static-first',
          'copy': 'No runtime public DB.',
        },
        {
          'label': 'RLS',
          'title': 'Hardened CMS',
          'copy': 'Admin write boundary.',
        },
        {
          'label': '0 USD',
          'title': 'Monthly Infra',
          'copy': 'Free deployment path.',
        },
      ],
    },
  ],
};

const stackMatrixContent = <String, Object?>{
  'schemaVersion': 2,
  'blocks': [
    {
      'type': 'architecturePanel',
      'items': [
        {
          'label': 'Client',
          'title': 'Flutter / Astro',
          'copy': 'Admin and static UI.',
        },
        {
          'label': 'Data',
          'title': 'Supabase',
          'copy': 'Postgres, Auth, Storage.',
        },
        {
          'label': 'Ops',
          'title': 'GitHub Actions',
          'copy': 'Manual static rebuilds.',
        },
      ],
    },
  ],
};

const aiLabContent = <String, Object?>{
  'schemaVersion': 2,
  'blocks': [
    {
      'type': 'callout',
      'label': 'Research',
      'title': 'From prototypes to deployable workflows',
      'copy': 'Frame each experiment by hypothesis, architecture, and result.',
    },
    {
      'type': 'ctaRow',
      'actions': [
        {'label': 'Open Lab', 'url': '#lab'},
      ],
    },
  ],
};

const webrtcMapContent = <String, Object?>{
  'schemaVersion': 2,
  'blocks': [
    {
      'type': 'architecturePanel',
      'items': [
        {
          'label': '01',
          'title': 'Signaling',
          'copy': 'Discovery and session setup.',
        },
        {
          'label': '02',
          'title': 'Peers',
          'copy': 'Direct transport and fallback paths.',
        },
        {
          'label': '03',
          'title': 'State',
          'copy': 'Sync, ordering, and recovery.',
        },
      ],
    },
  ],
};

const resumeCtaContent = <String, Object?>{
  'schemaVersion': 2,
  'blocks': [
    {
      'type': 'ctaRow',
      'actions': [
        {'label': 'Contact', 'url': '#contact'},
        {'label': 'Review Systems', 'url': '#projects'},
      ],
    },
  ],
};

const signalDesign = <String, Object?>{
  'accent': 'signal',
  'mediaUrl': '',
  'caption': '',
};

const minimalDesign = <String, Object?>{
  'accent': 'minimal',
  'mediaUrl': '',
  'caption': '',
};
