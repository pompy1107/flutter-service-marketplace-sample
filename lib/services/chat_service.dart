import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String receiverId,
    required String senderName,
  }) async {
    final senderId = _authService.currentUser!.uid;
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.collection('messages').add({
      'text': text,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'sender_name': senderName,
      'createdAt': FieldValue.serverTimestamp(),
      'is_read': false,
      'type': 'text',
      'image_url': '',
    });

    await chatRef.set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageType': 'text',
    }, SetOptions(merge: true));

    await chatRef.update({
      'unreadCount.$receiverId': FieldValue.increment(1),
    });
  }
}
