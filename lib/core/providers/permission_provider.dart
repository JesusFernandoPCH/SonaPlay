import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SonaPlay/core/services/permission_service.dart';

/// Permission service provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Audio permission state provider
final audioPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(permissionServiceProvider);
  return service.hasAudioPermission();
});
