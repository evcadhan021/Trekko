import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

Future<bool> isAdmin(WidgetRef ref) async {
  final role = await ref.read(userRoleProvider.future);

  return role == 'admin';
}
