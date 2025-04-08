import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recommendation_service.dart';

/// A provider that exposes a single RecommendationService instance.
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(
    /// The base URL of the FastAPI backend.
    baseUrl: 'http://192.168.1.154:8000',
  );
});
