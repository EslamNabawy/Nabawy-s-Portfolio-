import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/portfolio_admin_app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseConfig = readSupabaseConfig();

  if (!supabaseConfig.isValid) {
    runApp(
      const ConfigurationErrorApp(
        message:
            'Missing Supabase config. For desktop, set SUPABASE_ANON_KEY in your terminal or create supabase_config.json next to portfolio_admin.exe.',
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: supabaseConfig.url,
    anonKey: supabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: PortfolioAdminApp()));
}
