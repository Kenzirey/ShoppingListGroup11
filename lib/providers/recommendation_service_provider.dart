import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recommendation_service.dart';

/// Provider that exposes a RecommendationService instance
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService();
});