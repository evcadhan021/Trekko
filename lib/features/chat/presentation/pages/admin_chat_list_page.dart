import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/chat_repository.dart';

class AdminChatListPage extends ConsumerWidget {
  const AdminChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Pelanggan')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ChatRepository().getChatSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada chat dari pelanggan'));
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final userName = chat['userName']?.toString() ?? 'Pelanggan';
              final lastMessage = chat['lastMessage']?.toString() ?? '-';
              final userId = chat['userId']?.toString() ?? '';

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(userName),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.push('/admin-chat-detail', extra: userId);
                },
              );
            },
          );
        },
      ),
    );
  }
}
