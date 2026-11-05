import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart';
import 'core/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (returns false if keys not provided)
  final supabaseInitialized = await SupabaseClient.initialize();

  runApp(
    ProviderScope(
      child: MyApp(
        useSupabase: supabaseInitialized,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool useSupabase;

  const MyApp({
    super.key,
    required this.useSupabase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CoopControl',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
