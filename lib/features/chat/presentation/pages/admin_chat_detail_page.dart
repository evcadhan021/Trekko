import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../../data/chat_repository.dart';

class AdminChatDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const AdminChatDetailPage({super.key, required this.userId});

  @override
  ConsumerState<AdminChatDetailPage> createState() =>
      _AdminChatDetailPageState();
}

class _AdminChatDetailPageState extends ConsumerState<AdminChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository _chatRepository = ChatRepository();

  Future<void> _sendReply() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final text = _messageController.text.trim();

    if (currentUser == null || text.isEmpty) return;

    await _chatRepository.sendAdminReply(
      userId: widget.userId,
      adminId: currentUser.uid,
      message: text,
    );

    _messageController.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatRepository.markAllUserMessagesAsRead(widget.userId);
      ref.invalidate(adminChatUnreadCountProvider);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream = _chatRepository.getMessagesStream(widget.userId);

    return Scaffold(
      appBar: AppBar(title: const Text('Balas Chat')),
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
                      child: Text('Belum ada pesan dari pelanggan.'),
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
                    final senderName =
                        message['senderName']?.toString() ??
                        (isAdmin ? 'Admin' : 'Pengguna');
                    final text = message['message']?.toString() ?? '';

                    return Align(
                      alignment: isAdmin
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Column(
                          crossAxisAlignment: isAdmin
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderName,
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
                                    ? Colors.blue
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: isAdmin
                                      ? Colors.white
                                      : Colors.black87,
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
                        hintText: 'Ketik balasan untuk pelanggan...',
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
                    onPressed: _sendReply,
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
