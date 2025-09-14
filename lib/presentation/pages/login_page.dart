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

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _switchMode() {
    setState(() {
      isLoginMode = !isLoginMode;
    });
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, "/roots");
          } else if (state is EmailVerificationRequired) {
            Navigator.pushNamed(
              context,
              "/email-verification",
              arguments: state.email,
            );
          } else if (state is EmailVerificationSentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            height: 100.h,
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
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      // Header Section - Daha kompakt
                      SizedBox(height: 4.h),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // App Icon from assets
                            Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/notehive_icon.png',
                                  width: 20.w,
                                  height: 18.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.note_alt_rounded,
                                      size: 10.w,
                                      color: const Color(0xFFFFD700), // Sarı
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // Title - Daha küçük
                            Text(
                              "NoteHive",
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              isLoginMode ? "Welcome back" : "Create account",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Form Section - Taşma hatası düzeltildi
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mode Toggle - Daha küçük
                              Container(
                                height: 4.5.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: isLoginMode ? null : _switchMode,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          margin: EdgeInsets.all(0.4.w),
                                          decoration: BoxDecoration(
                                            color:
                                                isLoginMode
                                                    ? Colors.white
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow:
                                                isLoginMode
                                                    ? [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 6,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Sign In",
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    isLoginMode
                                                        ? Colors.black
                                                        : Colors.grey[600],
                                              ),
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
                                            milliseconds: 200,
                                          ),
                                          margin: EdgeInsets.all(0.4.w),
                                          decoration: BoxDecoration(
                                            color:
                                                !isLoginMode
                                                    ? Colors.white
                                                    : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow:
                                                !isLoginMode
                                                    ? [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 6,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Sign Up",
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    !isLoginMode
                                                        ? Colors.black
                                                        : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // Form Fields - Daha kompakt
                              if (!isLoginMode) ...[
                                _buildTextField(
                                  nameController,
                                  "Full Name",
                                  Icons.person_outline,
                                ),
                                SizedBox(height: 1.8.h),
                              ],

                              _buildTextField(
                                emailController,
                                "Email",
                                Icons.email_outlined,
                              ),
                              SizedBox(height: 1.8.h),

                              _buildTextField(
                                passwordController,
                                "Password",
                                Icons.lock_outline,
                                isPassword: true,
                                isPasswordVisible: isPasswordVisible,
                                onTogglePassword: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),

                              if (!isLoginMode) ...[
                                SizedBox(height: 1.8.h),
                                _buildTextField(
                                  confirmPasswordController,
                                  "Confirm Password",
                                  Icons.lock_outline,
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

                              SizedBox(height: 3.h),

                              // Submit Button - Daha küçük
                              SizedBox(
                                width: double.infinity,
                                height: 5.5.h,
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
                                                            12,
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
                                    backgroundColor: Colors.black,
                                    foregroundColor: const Color(
                                      0xFFFFD700,
                                    ), // Sarı
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  child:
                                      state is AuthLoading
                                          ? SizedBox(
                                            height: 2.5.h,
                                            width: 2.5.h,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xFFFFD700)),
                                                ),
                                          )
                                          : Text(
                                            isLoginMode
                                                ? "Sign In"
                                                : "Create Account",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),

                              if (isLoginMode) ...[
                                SizedBox(height: 2.h),
                                Center(
                                  child: TextButton(
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
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Footer - Daha küçük
                      SizedBox(height: 3.h),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "By continuing, you agree to our Terms of Service and Privacy Policy",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
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
    return Container(
      height: 5.5.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Açık sarı
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.black, size: 18.sp),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[600],
                      size: 18.sp,
                    ),
                    onPressed: onTogglePassword,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.2.h,
          ),
        ),
      ),
    );
  }
}
