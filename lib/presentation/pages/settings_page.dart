import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/language/language_cubit.dart';
import '../../utils/theme/theme_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state.mode;

    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar Bölümü
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _avatar != null
                          ? FileImage(_avatar!)
                          : const NetworkImage(
                                'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg',
                              )
                              as ImageProvider,
                ),
                IconButton(
                  onPressed: _pickAvatar,
                  icon: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Tema Değişimi
          SwitchListTile(
            title: const Text("Karanlık Mod"),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              context.read<ThemeCubit>().setTheme(
                val ? ThemeMode.dark : ThemeMode.light,
              );
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(),

          SwitchListTile(
            title: const Text("Türkçe"),
            value: _isTurkish,
            onChanged: (val) async {
              await _toggleLanguage(val);
              context.read<LanguageCubit>().toggleLanguage(val);
            },
            secondary: const Icon(Icons.language),
          ),
        ],
      ),
    );
  }
}
