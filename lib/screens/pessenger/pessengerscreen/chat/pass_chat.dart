import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/utils.dart';

class PassChat extends StatefulWidget {
  final String passId;
  final String driverId;
  final String driverName;
  const PassChat(
      {super.key,
      required this.passId,
      required this.driverId,
      required this.driverName});

  @override
  State<PassChat> createState() => _PassChatState();
}

class _PassChatState extends State<PassChat> {
  late TextEditingController _messageController;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  sendNotification1(String token, String message) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': 1,
      'status': 'done',
      'message': 'New Message'
    };
    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization':
                    'key=AAAADnkker0:APA91bEJO2ufASuDfJNV6yaKiiAES-O0X-jkQW2UL1ciN8hVCgXkCKSsKAQ4jO_7UNUzwrwVAC0iX3Ihu4xvLwsJifoYkVzo1QbYMyJyBXNj4_5f-S39WR9AI2QsYGzBc_jz5myyY5re'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': 'New Message',
                  'body': message
                },
                'priority': 'normal',
                'data': data,
                'to': token
              }));
      if (response.statusCode != 200) {
        Utils().toastMessage("Something went wrong");
      }
    } catch (e) {
      Utils().toastMessage(e.toString());
    }
  }

  Future<String> getDriverToken() async {
    final token = await firestore
        .collection('app')
        .doc('user')
        .collection('driver')
        .doc(widget.driverId)
        .get();
    final tokenData = token.data();
    if (tokenData != null) {
      return tokenData['token'];
    }
    return '';
  }

  void _sendMessage(String message) async {
    FirebaseFirestore.instance
        .collection('chats')
        .doc('${widget.driverId}_${widget.passId}')
        .collection('messages')
        .add({
      'sender': 'passenger',
      'message': message,
      'timestamp': DateTime.now(),
    });

    _messageController.clear();

    String driverToken = await getDriverToken();
    sendNotification1(driverToken, message);
  }

  void _deleteMessage(String messageId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc('${widget.driverId}_${widget.passId}')
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.driverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc('${widget.driverId}_${widget.passId}')
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No Messages'),
                  );
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var messageTime = message['timestamp'].toDate();
                    var formattedTime = DateFormat.jm().format(messageTime);
                    return Dismissible(
                      key: Key(message.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteMessage(message.id);
                      },
                      child: ListTile(
                        title: Text(message['message']),
                        subtitle: Text(
                            '${message['sender'] == 'passenger' ? 'You' : widget.driverName} - $formattedTime'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text.trim());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
