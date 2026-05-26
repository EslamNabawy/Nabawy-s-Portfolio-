import 'package:flutter/material.dart';

enum AdminStatusTone { neutral, success, warning, danger, info }

class AdminPanel extends StatelessWidget {
  const AdminPanel({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions.isNotEmpty) ...actions,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({
    super.key,
    required this.label,
    this.tone = AdminStatusTone.neutral,
    this.icon,
  });

  final String label;
  final AdminStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = _StatusPalette.forTone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: palette.foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: palette.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminMetricTile extends StatelessWidget {
  const AdminMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.tone = AdminStatusTone.neutral,
  });

  final String label;
  final String value;
  final AdminStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = _StatusPalette.forTone(tone);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: palette.foreground,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

class CommandButton extends StatelessWidget {
  const CommandButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class ValidationList extends StatelessWidget {
  const ValidationList({super.key, required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const AdminStatusChip(
        label: 'Ready',
        tone: AdminStatusTone.success,
        icon: Icons.check_circle_outline,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final message in messages)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
          ),
      ],
    );
  }
}

class ResponsiveTwoPane extends StatelessWidget {
  const ResponsiveTwoPane({
    super.key,
    required this.primary,
    required this.secondary,
  });

  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [primary, const SizedBox(height: 16), secondary],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: primary),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: secondary),
          ],
        );
      },
    );
  }
}

final class _StatusPalette {
  const _StatusPalette(this.background, this.border, this.foreground);

  final Color background;
  final Color border;
  final Color foreground;

  static _StatusPalette forTone(AdminStatusTone tone) {
    return switch (tone) {
      AdminStatusTone.success => const _StatusPalette(
        Color(0xFFDCFCE7),
        Color(0xFF86EFAC),
        Color(0xFF166534),
      ),
      AdminStatusTone.warning => const _StatusPalette(
        Color(0xFFFFF7ED),
        Color(0xFFFDBA74),
        Color(0xFF9A3412),
      ),
      AdminStatusTone.danger => const _StatusPalette(
        Color(0xFFFEE2E2),
        Color(0xFFFCA5A5),
        Color(0xFF991B1B),
      ),
      AdminStatusTone.info => const _StatusPalette(
        Color(0xFFE0F2FE),
        Color(0xFF7DD3FC),
        Color(0xFF075985),
      ),
      AdminStatusTone.neutral => const _StatusPalette(
        Color(0xFFF1F5F9),
        Color(0xFFCBD5E1),
        Color(0xFF334155),
      ),
    };
  }
}
