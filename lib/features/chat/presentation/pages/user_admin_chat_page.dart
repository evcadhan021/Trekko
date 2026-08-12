import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../data/chat_repository.dart';

class UserAdminChatPage extends ConsumerStatefulWidget {
  const UserAdminChatPage({super.key});

  @override
  ConsumerState<UserAdminChatPage> createState() => _UserAdminChatPageState();
}

class _UserAdminChatPageState extends ConsumerState<UserAdminChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository _chatRepository = ChatRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _chatRepository.markAllAdminMessagesAsRead(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    final text = _messageController.text.trim();

    if (user == null || text.isEmpty) return;

    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userProfile = profile.data();
    final userName = ChatRepository.resolveDisplayName(
      userName: user.displayName,
      userProfile: userProfile,
      fallback: 'Pelanggan',
    );

    await _chatRepository.sendMessageToAdmin(
      userId: user.uid,
      userName: userName,
      productName: 'Chat dengan Admin',
      message: text,
    );

    _messageController.clear();
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    final stream = _chatRepository.getMessagesStream(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Admin')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Belum ada percakapan dengan admin. Silakan kirim pertanyaan Anda.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isAdmin =
                        message['senderId'] == AdminConstants.adminUid;
                    final text = message['message']?.toString() ?? '';

                    return Align(
                      alignment: isAdmin
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Column(
                          crossAxisAlignment: isAdmin
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              isAdmin ? 'Admin' : 'Anda',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? Colors.grey.shade200
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: isAdmin
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan untuk admin...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    mini: true,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
