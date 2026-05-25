import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/overview_screen.dart';
import '../features/deployment/presentation/screens/deploy_screen.dart';
import '../features/developer_tools/presentation/screens/code_tools_screen.dart';
import '../features/projects/presentation/screens/experiment_list_screen.dart';
import '../features/projects/presentation/screens/project_list_screen.dart';
import '../features/projects/presentation/screens/skill_list_screen.dart';
import '../features/settings/presentation/screens/publish_log_screen.dart';
import '../features/settings/presentation/screens/site_config_screen.dart';
import '../shared/ui/admin_shell.dart';

class PortfolioAdminApp extends StatelessWidget {
  const PortfolioAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portfolio Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00836B),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          foregroundColor: Color(0xFF101312),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFC7D2CC)),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        dataTableTheme: const DataTableThemeData(
          headingRowColor: WidgetStatePropertyAll(Color(0xFFF1F5F9)),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(authSessionProvider);
    return sessionState.when(
      data: (session) {
        if (session == null || session.isExpired) {
          return const LoginScreen();
        }
        return const AdminHome();
      },
      loading: () => const BootScreen(message: 'Checking admin session...'),
      error: (error, _) => LoginScreen(
        initialError: error is AppException
            ? error.message
            : 'Could not verify admin session. Sign in again.',
      ),
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  AdminSection _section = AdminSection.overview;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedSection: _section,
      onSectionChanged: (section) => setState(() => _section = section),
      child: switch (_section) {
        AdminSection.overview => const OverviewScreen(),
        AdminSection.projects => const ProjectListScreen(),
        AdminSection.skills => const SkillListScreen(),
        AdminSection.experiments => const ExperimentListScreen(),
        AdminSection.config => const SiteConfigScreen(),
        AdminSection.deploy => const DeployScreen(),
        AdminSection.publishLog => const PublishLogScreen(),
        AdminSection.codeTools => const CodeToolsScreen(),
      },
    );
  }
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BootScreen(message: message),
    );
  }
}

class BootScreen extends StatelessWidget {
  const BootScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
