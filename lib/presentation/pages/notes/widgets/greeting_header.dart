import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notehive/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GreetingHeader shows user's avatar, a time-based greeting and display name.
/// Avatar tries local saved image, then Firebase photoURL, then a fallback.
class GreetingHeader extends StatefulWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader> {
  File? _avatar;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("user_avatar");
    if (path != null && File(path).existsSync()) {
      setState(() => _avatar = File(path));
    }
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return l10n.goodMorning;
    if (hour >= 12 && hour < 17) return l10n.goodAfternoon;
    if (hour >= 17 && hour < 22) return l10n.goodEvening;
    return l10n.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final emailName = (user?.email ?? '').split('@').first;
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (emailName.isNotEmpty ? emailName : 'User');

    final photoUrl = user?.photoURL;
    ImageProvider avatarProvider;
    if (_avatar != null) {
      avatarProvider = FileImage(_avatar!);
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarProvider = NetworkImage(photoUrl);
    } else {
      avatarProvider = const NetworkImage(
        'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: avatarProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


