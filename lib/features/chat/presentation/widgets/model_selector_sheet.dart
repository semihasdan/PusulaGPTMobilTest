import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/ai_model.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/theme/app_theme.dart';

class ModelSelectorSheet extends ConsumerWidget {
  const ModelSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: AppTheme.mediumText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildModelList(context, ref, selectedModel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.mediumText.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select AI Model',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the AI assistant that best fits your needs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelList(BuildContext context, WidgetRef ref, AiModel selectedModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: AiModel.availableModels.length,
      itemBuilder: (context, index) {
        final model = AiModel.availableModels[index];
        final isSelected = model.id == selectedModel.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryBlue.withOpacity(0.1) 
                : AppTheme.darkBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryBlue 
                  : AppTheme.mediumText.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      model.logoPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to gradient container
                        return Container(
                          decoration: BoxDecoration(
                            gradient: _getModelGradient(model.id),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              model.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            title: Text(
              model.displayName,
              style: TextStyle(
                color: AppTheme.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                model.description,
                style: TextStyle(
                  color: AppTheme.mediumText,
                  fontSize: 14,
                ),
              ),
            ),
            trailing: isSelected
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : null,
            onTap: () {
              ref.read(selectedModelProvider.notifier).selectModel(model);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  LinearGradient _getModelGradient(String modelId) {
    switch (modelId) {
      case 'pusula':
        return AppTheme.primaryGradient;
      case 'comed':
        return const LinearGradient(
          colors: [AppTheme.emerald, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'diabet':
        return const LinearGradient(
          colors: [AppTheme.rose, AppTheme.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }
}