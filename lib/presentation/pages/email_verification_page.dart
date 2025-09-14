import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../logic/auth/auth_bloc.dart';

class EmailVerificationPage extends StatelessWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // Icon
                Container(
                  width: 20.w,
                  height: 20.w,
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
                      height: 20.w,
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

                SizedBox(height: 4.h),

                // Title
                Text(
                  "Email Adresinizi Kontrol Edin",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: 2.h),

                // Description
                Text(
                  "Doğrulama linki gönderildi:",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 1.h),

                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 3.h),

                // Info Box
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFFFFD700),
                        size: 24.sp,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Email adresinizi kontrol edin ve hesabınızı aktifleştirmek için doğrulama linkine tıklayın.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Spam warning
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: const Color(0xFFFFD700),
                              size: 18.sp,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                "Doğrulama maili spam klasörüne düşmüş olabilir. Lütfen spam klasörünüzü de kontrol edin.",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 2.h),
                      Text(
                        "Doğrulama tamamlandıktan sonra hesabınıza giriş yapabilirsiniz.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Resend Button
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is EmailVerificationSentSuccess) {
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
                    } else if (state is AuthFailure) {
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
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 5.5.h,
                      child: ElevatedButton(
                        onPressed:
                            state is AuthLoading
                                ? null
                                : () {
                                  context.read<AuthBloc>().add(
                                    SendEmailVerification(),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: const Color(0xFFFFD700), // Sarı
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
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFD700),
                                    ),
                                  ),
                                )
                                : Text(
                                  "Doğrulama Mailini Tekrar Gönder",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 2.h),

                // Back to Login Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Giriş Sayfasına Dön",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // Footer
                Text(
                  "Email gelmedi mi? Spam klasörünüzü kontrol edin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
