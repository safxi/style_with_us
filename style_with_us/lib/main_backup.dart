import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Backup of original main.dart before Supabase migration.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  const publishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  if (publishableKey.isNotEmpty) {
    Stripe.publishableKey = publishableKey;
  }
  runApp(const ProviderScope(child: StyleWithUsApp()));
}

class StyleWithUsApp extends StatelessWidget {
  const StyleWithUsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Style With Us',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          routerConfig: appRouter,
        );
      },
    );
  }
}
