import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../logic/language/language_cubit.dart';
import 'package:notehive/l10n/app_localizations.dart';
import '../../utils/theme/theme_cubit.dart';
import '../../logic/auth/auth_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _avatar;
  bool _isTurkish = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _loadLanguage();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("user_avatar");
    if (path != null && File(path).existsSync()) {
      setState(() => _avatar = File(path));
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/avatar.png");
      await File(picked.path).copy(file.path);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_avatar", file.path);

      setState(() => _avatar = file);
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isTr = prefs.getBool("isTurkish") ?? true;
    setState(() => _isTurkish = isTr);
  }

  Future<void> _toggleLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isTurkish", value);
    setState(() => _isTurkish = value);

    // TODO: localization cubit/bloc çağırabilirsin
  }

  void _showDeleteAccountDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        return CupertinoAlertDialog(
          title: Text(l10n?.deleteConfirmTitle ?? 'Hesabı Sil'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n?.deleteConfirmBody ??
                  'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.cancel ?? 'İptal'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthDeleteAccountRequested());
              },
              child: Text(l10n?.delete ?? 'Sil'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        return CupertinoAlertDialog(
          title: Text(l10n?.logoutConfirmTitle ?? 'Çıkış Yap'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n?.logoutConfirmBody ?? 'Çıkış yapmak istediğinize emin misiniz?',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.cancel ?? 'İptal'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: Text(l10n?.logout ?? 'Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state.mode;
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // User logged out or account deleted, navigate to login
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n?.settings ?? 'Ayarlar',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          children: [
            // Profile Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              padding: EdgeInsets.all(2.0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: CircleAvatar(
                          radius: 9.w,
                          backgroundColor: Colors.grey[100],
                          backgroundImage:
                              _avatar != null
                                  ? FileImage(_avatar!)
                                  : const NetworkImage(
                                        'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg',
                                      )
                                      as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 3.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.yourAccount ?? 'Hesabınız',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          userEmail.isNotEmpty ? userEmail : "Kullanıcı",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(height: 1.0.h),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickAvatar,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.8.h,
                                ),
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text(
                                l10n?.changeAvatar ?? 'Avatarı Değiştir',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            TextButton(
                              onPressed: _showLogoutDialog,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.8.h,
                                ),
                              ),
                              child: Text(
                                l10n?.logout ?? 'Çıkış Yap',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.0.h),

            // Settings Cards
            Text(
              l10n?.general ?? 'Genel',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 0.8.h),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                children: [
                  // change theme
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 2.0.w,
                      vertical: 0.7.h,
                    ),
                    leading: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Colors.grey[700],
                      size: 22,
                    ),
                    title: Text(
                      l10n?.darkMode ?? 'Karanlık Mod',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (val) {
                        context.read<ThemeCubit>().setTheme(
                          val ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeColor: Colors.black,
                      activeTrackColor: Colors.grey[300],
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  // Dil Değişimi
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 2.0.w,
                      vertical: 0.7.h,
                    ),
                    leading: Icon(
                      Icons.language,
                      color: Colors.grey[700],
                      size: 22,
                    ),
                    title: Text(
                      l10n?.languageTitle ?? 'Dil',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _isTurkish
                          ? (l10n?.turkish ?? 'Türkçe')
                          : (l10n?.english ?? 'İngilizce'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    trailing: Switch(
                      value: _isTurkish,
                      onChanged: (val) async {
                        await _toggleLanguage(val);
                        context.read<LanguageCubit>().toggleLanguage(val);
                      },
                      activeColor: Colors.black,
                      activeTrackColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Account Actions
            Text(
              l10n?.account ?? 'Hesap',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 0.8.h),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                children: [
                  // Logout
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 2.0.w,
                      vertical: 0.7.h,
                    ),
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.black,
                      size: 22,
                    ),
                    title: Text(
                      l10n?.logout ?? 'Çıkış Yap',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onTap: _showLogoutDialog,
                  ),

                  const Divider(height: 1, thickness: 0.5),

                  // Delete Account
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 2.0.w,
                      vertical: 0.7.h,
                    ),
                    leading: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: 22,
                    ),
                    title: Text(
                      l10n?.deleteAccount ?? 'Hesabı Sil',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}
