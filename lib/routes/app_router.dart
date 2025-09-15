import 'package:flutter/material.dart';
import 'package:notehive/presentation/pages/home_page.dart';
import 'package:notehive/presentation/pages/settings_page.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/notes/notes_page.dart';
import '../presentation/pages/email_verification_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/root':
        return MaterialPageRoute(builder: (_) => const RootPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/email-verification':
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => EmailVerificationPage(email: email));
      case '/notes':
        return MaterialPageRoute(builder: (_) => const NotesPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('404 - Page Not Found')),
              ),
        );
    }
  }
}
