import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:notehive/utils/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/auth_service.dart';
import 'firebase_options.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/language/language_cubit.dart';
import 'routes/app_router.dart';
import 'utils/theme/theme_cubit.dart';
import 'utils/theme/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i initialize et
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //Firebase App Check'i aktif et
  await FirebaseAppCheck.instance.activate(
    //appCheck actice codde
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(AuthService())),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkAuth()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return MaterialApp(
                  title: 'NoteHive',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: state.mode,
                  locale: locale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [Locale('en'), Locale('tr')],
                  onGenerateRoute: AppRouter.onGenerateRoute,
                  initialRoute: '/',
                );
              },
            );
          },
        );
      },
    );
  }
}
