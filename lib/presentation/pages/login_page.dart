import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../logic/auth/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoginMode = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _formController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formAnimation;

  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _formAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
    _formController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _formController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      isLoginMode = !isLoginMode;
    });
    _formController.reset();
    _formController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, "/navigation_page");
          }
        },
        builder: (context, state) {
          return Container(
            height: 100.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6750A4),
                  const Color.fromARGB(255, 255, 234, 138),
                  const Color(0xFF6750A4),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  children: [
                    // Logo ve Başlık - Daha kompakt
                    SizedBox(height: 3.h),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.note_alt_rounded,
                              size: 11.w,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "NoteHive",
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            isLoginMode
                                ? "Welcome back to your notes!"
                                : "Create your account to start",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Form Container - Daha geniş ve efektif
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _formAnimation,
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Mode Toggle - Daha büyük ve efektif
                                Container(
                                  height: 6.h,
                                  padding: EdgeInsets.all(0.5.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap:
                                              isLoginMode ? null : _switchMode,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isLoginMode
                                                      ? Colors.white
                                                      : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow:
                                                  isLoginMode
                                                      ? [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ]
                                                      : null,
                                            ),
                                            child: Text(
                                              "Sign In",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    isLoginMode
                                                        ? const Color(
                                                          0xFF6750A4,
                                                        )
                                                        : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap:
                                              !isLoginMode ? null : _switchMode,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  !isLoginMode
                                                      ? Colors.white
                                                      : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow:
                                                  !isLoginMode
                                                      ? [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ]
                                                      : null,
                                            ),
                                            child: Text(
                                              "Sign Up",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    !isLoginMode
                                                        ? const Color(
                                                          0xFF6750A4,
                                                        )
                                                        : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 4.h),

                                // Form Fields - Daha büyük ve efektif
                                if (!isLoginMode) ...[
                                  _buildTextField(
                                    nameController,
                                    "Full Name",
                                    Icons.person_outline_rounded,
                                  ),
                                  SizedBox(height: 2.5.h),
                                ],

                                _buildTextField(
                                  emailController,
                                  "Email Address",
                                  Icons.email_outlined,
                                ),
                                SizedBox(height: 2.5.h),

                                _buildTextField(
                                  passwordController,
                                  "Password",
                                  Icons.lock_outline_rounded,
                                  isPassword: true,
                                  isPasswordVisible: isPasswordVisible,
                                  onTogglePassword: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),

                                if (!isLoginMode) ...[
                                  SizedBox(height: 2.5.h),
                                  _buildTextField(
                                    confirmPasswordController,
                                    "Confirm Password",
                                    Icons.lock_outline_rounded,
                                    isPassword: true,
                                    isPasswordVisible: isConfirmPasswordVisible,
                                    onTogglePassword: () {
                                      setState(() {
                                        isConfirmPasswordVisible =
                                            !isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ],

                                SizedBox(height: 4.h),

                                // Login/Register Button - Daha büyük ve efektif
                                SizedBox(
                                  width: double.infinity,
                                  height: 6.5.h,
                                  child: ElevatedButton(
                                    onPressed:
                                        state is AuthLoading
                                            ? null
                                            : () {
                                              if (isLoginMode) {
                                                context.read<AuthBloc>().add(
                                                  AuthLoginRequested(
                                                    emailController.text,
                                                    passwordController.text,
                                                  ),
                                                );
                                              } else {
                                                if (passwordController.text !=
                                                    confirmPasswordController
                                                        .text) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        "Passwords do not match",
                                                      ),
                                                      backgroundColor:
                                                          Colors.red[600],
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                context.read<AuthBloc>().add(
                                                  AuthRegisterRequested(
                                                    emailController.text,
                                                    passwordController.text,
                                                    nameController.text,
                                                  ),
                                                );
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6750A4),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      shadowColor: const Color(
                                        0xFF6750A4,
                                      ).withOpacity(0.3),
                                    ),
                                    child:
                                        state is AuthLoading
                                            ? SizedBox(
                                              height: 3.h,
                                              width: 3.h,
                                              child:
                                                  const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                            )
                                            : Text(
                                              isLoginMode
                                                  ? "Sign In"
                                                  : "Create Account",
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                  ),
                                ),

                                if (isLoginMode) ...[
                                  SizedBox(height: 2.5.h),
                                  TextButton(
                                    onPressed: () {
                                      context.read<AuthBloc>().add(
                                        AuthResetPasswordRequested(
                                          emailController.text,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],

                                SizedBox(height: 1.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Footer - Daha küçük
                    SizedBox(height: 2.h),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "By continuing, you agree to our Terms of Service\nand Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    return SizedBox(
      height: 7.h,
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(fontSize: 15.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey[400]),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20.sp,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[400],
                      size: 20.sp,
                    ),
                    onPressed: onTogglePassword,
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
      ),
    );
  }
}
