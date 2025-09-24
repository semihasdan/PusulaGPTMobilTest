import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/chat_provider.dart';

class AIResponseItem extends ConsumerStatefulWidget {
  final ChatMessage message;

  const AIResponseItem({
    super.key,
    required this.message,
  });

  @override
  ConsumerState<AIResponseItem> createState() => _AIResponseItemState();
}

class _AIResponseItemState extends ConsumerState<AIResponseItem> {
  // ✅ Removed thinking process state since it's no longer used

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Main Response Text (thinking process removed from final response)
          _buildResponseText(),  
                  
          // ✅ Streamlined Action Toolbar
          _buildActionToolbar(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }

  // ✅ Removed thinking process widget - only shown during typing, not in final response

  Widget _buildResponseText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        widget.message.content ?? '', // ✅ Handle null content gracefully
        style: const TextStyle(
          color: AppTheme.lightText,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildActionToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Like button
          _buildActionButton(
            icon: widget.message.feedbackState == FeedbackState.liked
                ? Icons.thumb_up
                : Icons.thumb_up_outlined,
            onPressed: widget.message.feedbackState == FeedbackState.disliked
                ? null
                : () => _handleLike(),
            isActive: widget.message.feedbackState == FeedbackState.liked,
          ),
          
          // Dislike button (transforms to check when feedback submitted)
          _buildActionButton(
            icon: widget.message.feedbackState == FeedbackState.disliked
                ? Icons.check
                : Icons.thumb_down_outlined,
            onPressed: widget.message.feedbackState == FeedbackState.liked
                ? null
                : () => _handleDislike(),
            isActive: widget.message.feedbackState == FeedbackState.disliked,
          ),
          
          // Regenerate button
          _buildActionButton(
            icon: Icons.refresh,
            onPressed: () => _handleRegenerate(),
          ),
          
          // Copy button
          _buildActionButton(
            icon: Icons.content_copy,
            onPressed: () => _handleCopy(),
          ),
          
          // ✅ Removed Share and More Options buttons as requested
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isActive 
              ? AppTheme.primaryBlue.withOpacity(0.2)
              : Colors.transparent,
          foregroundColor: isActive 
              ? AppTheme.primaryBlue
              : (onPressed != null ? AppTheme.mediumText : AppTheme.mediumText.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _handleLike() {
    ref.read(chatProvider.notifier).updateMessageFeedback(
      widget.message.id,
      FeedbackState.liked,
    );
  }

  void _handleDislike() {
    // ✅ If already disliked, show confirmation message
    if (widget.message.feedbackState == FeedbackState.disliked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geri bildirim alındı'),
          duration: Duration(seconds: 2),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    } else {
      // ✅ Show feedback dialog for new dislike
      _showFeedbackDialog();
    }
  }

  void _handleRegenerate() {
    ref.read(chatProvider.notifier).regenerateResponse(widget.message.id);
  }

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yanıt panoya kopyalandı'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ Removed unused share and more options methods

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Ek geri bildirim sağlayın',
          style: TextStyle(
            color: AppTheme.lightText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bu yanıtı beğenmeme nedeninizi belirtebilirsiniz:',
              style: TextStyle(
                color: AppTheme.mediumText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.lightText),
              decoration: InputDecoration(
                hintText: 'Geri bildiriminizi buraya yazın...',
                hintStyle: TextStyle(
                  color: AppTheme.mediumText.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.mediumText.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppTheme.mediumText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final feedback = feedbackController.text.trim();
              ref.read(chatProvider.notifier).updateMessageFeedback(
                widget.message.id,
                FeedbackState.disliked,
                feedback: feedback.isNotEmpty ? feedback : null,
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Gönder',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}