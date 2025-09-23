class AiModel {
  final String id;
  final String name;
  final String description;
  final String displayName;
  final String logoPath;

  const AiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.displayName,
    required this.logoPath,
  });

  static const List<AiModel> availableModels = [
    AiModel(
      id: 'pusula',
      name: 'PusulaGPT',
      description: 'General medical AI assistant',
      displayName: 'PusulaGPT (General)',
      logoPath: 'assets/logo/pusula_logo.png',
    ),
    AiModel(
      id: 'comed',
      name: 'ComedGPT',
      description: 'Specialized in emergency medicine',
      displayName: 'ComedGPT (Clinical)',
      logoPath: 'assets/logo/comed_logo.png',
    ),
    AiModel(
      id: 'diabet',
      name: 'MedDiabet',
      description: 'Diabetes management specialist',
      displayName: 'MedDiabet (Specialized)',
      logoPath: 'assets/logo/med_diyabet_logo.png',
    ),
  ];

  static AiModel getById(String id) {
    return availableModels.firstWhere(
      (model) => model.id == id,
      orElse: () => availableModels.first,
    );
  }
}