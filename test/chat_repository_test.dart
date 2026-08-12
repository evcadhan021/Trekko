import 'package:flutter_test/flutter_test.dart';
import 'package:trekko/features/chat/data/chat_repository.dart';

void main() {
  group('ChatRepository.resolveDisplayName', () {
    test('prefers actual profile name over generic auth name', () {
      final name = ChatRepository.resolveDisplayName(
        userName: 'User',
        userProfile: {'name': 'pengguna1'},
        fallback: 'Pelanggan',
      );

      expect(name, 'pengguna1');
    });

    test('uses auth display name when profile name is missing', () {
      final name = ChatRepository.resolveDisplayName(
        userName: 'pengguna2',
        userProfile: {},
        fallback: 'Pelanggan',
      );

      expect(name, 'pengguna2');
    });

    test('falls back to generic label when no names are available', () {
      final name = ChatRepository.resolveDisplayName(
        userName: null,
        userProfile: null,
        fallback: 'Pelanggan',
      );

      expect(name, 'Pelanggan');
    });
  });
}
