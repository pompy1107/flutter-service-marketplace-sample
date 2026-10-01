import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String senderName;
  const ChatScreen({super.key, required this.chatId, required this.receiverId, required this.senderName});
  @override State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final text = TextEditingController();
  final chats = ChatService();
  Future<void> send() async {
    final value = text.text.trim();
    if (value.isEmpty) return;
    await chats.sendMessage(chatId: widget.chatId, text: value, receiverId: widget.receiverId, senderName: widget.senderName);
    text.clear();
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chat')),
    body: Column(children: [
      Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').orderBy('createdAt').snapshots(), builder: (_, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        return ListView.builder(itemCount: docs.length, itemBuilder: (_, i) { final d = docs[i].data() as Map<String,dynamic>; return ListTile(title: Text(d['text']?.toString() ?? ''), subtitle: Text(d['sender_name']?.toString() ?? '')); });
      })),
      SafeArea(child: Row(children: [Expanded(child: TextField(controller: text, decoration: const InputDecoration(hintText: 'Message'))), IconButton(onPressed: send, icon: const Icon(Icons.send))]))
    ]),
  );
}
