import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final guidProvider = Provider<String>((ref) {
  return "95ae44bc-1022-460c-8e94-c5c7459fd3f1"; 
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final guid = ref.watch(guidProvider);
  return ApiService(guid);
});
