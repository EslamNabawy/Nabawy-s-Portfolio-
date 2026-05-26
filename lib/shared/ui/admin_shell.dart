import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';
import 'admin_status_strip.dart';

enum AdminSection {
  overview('Overview', Icons.space_dashboard_outlined),
  projects('Projects', Icons.view_list_outlined),
  skills('Skills', Icons.bolt_outlined),
  experiments('Lab', Icons.science_outlined),
  designStudio('Design Studio', Icons.palette_outlined),
  sections('Sections', Icons.dashboard_customize_outlined),
  config('Site Config', Icons.tune_outlined),
  deploy('Deploy', Icons.rocket_launch_outlined),
  healthChecks('Health Checks', Icons.health_and_safety_outlined),
  publishLog('Publish Log', Icons.history_outlined),
  codeTools('Code Tools', Icons.code);

  const AdminSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

class AdminShell extends ConsumerWidget {
  const AdminShell({
    super.key,
    required this.selectedSection,
    required this.onSectionChanged,
    required this.child,
  });

  final AdminSection selectedSection;
  final ValueChanged<AdminSection> onSectionChanged;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedSection.label),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                session?.email ?? 'Authenticated admin',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _signOut(context, ref),
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const AdminStatusStrip(),
          Expanded(
            child: Row(
              children: [
                _AdminSidebar(
                  selectedSection: selectedSection,
                  onSectionChanged: onSectionChanged,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).signOut();
      ref.invalidate(authSessionProvider);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out failed: $error')));
    }
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selectedSection,
    required this.onSectionChanged,
  });

  final AdminSection selectedSection;
  final ValueChanged<AdminSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final groups = const <_NavGroup>[
      _NavGroup('Command', [AdminSection.overview]),
      _NavGroup('Content', [
        AdminSection.projects,
        AdminSection.skills,
        AdminSection.experiments,
        AdminSection.config,
      ]),
      _NavGroup('Design', [AdminSection.designStudio, AdminSection.sections]),
      _NavGroup('Operations', [
        AdminSection.deploy,
        AdminSection.healthChecks,
        AdminSection.publishLog,
      ]),
      _NavGroup('Tools', [AdminSection.codeTools]),
    ];
    return SizedBox(
      width: 240,
      child: Material(
        color: const Color(0xFFF8FAFC),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Text(
                'Portfolio CMS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            for (final group in groups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Text(
                  group.label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              for (final section in group.sections)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: NavigationTile(
                    icon: section.icon,
                    label: section.label,
                    selected: selectedSection == section,
                    onTap: () => onSectionChanged(section),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _NavGroup {
  const _NavGroup(this.label, this.sections);

  final String label;
  final List<AdminSection> sections;
}

class NavigationTile extends StatelessWidget {
  const NavigationTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected ? colorScheme.primaryContainer : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPlaceholder extends StatelessWidget {
  const AdminPlaceholder({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
