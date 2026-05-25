import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/app/portfolio_admin_app.dart';

void main() {
  testWidgets('shows configuration error when Supabase env is missing', (
    tester,
  ) async {
    const message =
        'Missing Supabase config. For desktop, set SUPABASE_ANON_KEY in your terminal or create supabase_config.json next to portfolio_admin.exe.';

    await tester.pumpWidget(const ConfigurationErrorApp(message: message));

    expect(find.text(message), findsOneWidget);
  });
}
