import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const publishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  if (publishableKey.isNotEmpty) {
    Stripe.publishableKey = publishableKey;
  }
  
  // Initialize Push Notifications in background to avoid blocking app launch
  NotificationService().init().catchError((e) {
    debugPrint("Failed to init Push Notifications: $e");
  });

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

