import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaginationLoadingIndicator extends StatelessWidget {
  final String? message;

  const PaginationLoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message ?? 'Loading older messages...',
            style: TextStyle(
              color: AppTheme.mediumText.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}