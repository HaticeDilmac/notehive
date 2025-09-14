import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../logic/auth/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check auth status after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        print("Checking auth status...");
        context.read<AuthBloc>().add(CheckAuthStatus());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => true, // All statae change listen
      listener: (context, state) {
        print("SplashPage received state: $state");
        if (state is AuthSuccess) {
          print("AuthSuccess - navigating to notes");
          // User is authenticated and email is verified
          Navigator.pushReplacementNamed(context, '/root');
        } else if (state is EmailVerificationRequired) {
          print("EmailVerificationRequired - navigating to email verification");
          // User exists but email not verified
          Navigator.pushReplacementNamed(
            context,
            '/email-verification',
            arguments: state.email,
          );
        } else if (state is AuthFailure || state is AuthInitial) {
          print("AuthFailure or AuthInitial - navigating to login");
          // User not authenticated or initial state
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          print("Unknown state: $state");
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFF8E1),
                Colors.white,
                const Color(0xFFFFF8E1),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/notehive_icon.png',
                      width: 25.w,
                      height: 25.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.note_alt_rounded,
                          size: 12.w,
                          color: const Color(0xFFFFD700),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'NoteHive',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).canvasColor,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  'Your Digital Notebook',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
