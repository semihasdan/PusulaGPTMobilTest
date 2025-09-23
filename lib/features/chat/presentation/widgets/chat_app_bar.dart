import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/theme/app_theme.dart';

class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onModelSelectorTap;
  final VoidCallback onProfileTap;

  const ChatAppBar({
    super.key,
    required this.onModelSelectorTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: AppTheme.darkCard.withOpacity(0.8),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.lightText),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedModel.name,
                style: const TextStyle(
                  color: AppTheme.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: onModelSelectorTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Change Model',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.primaryBlue,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryBlue,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}