import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverChat extends StatefulWidget {
  final String driverId;
  final String passId;
  final String passName;

  const DriverChat(
      {required this.driverId, required this.passId, required this.passName});

  @override
  State<DriverChat> createState() => _DriverChatState();
}

class _DriverChatState extends State<DriverChat> {
  late TextEditingController _messageController;

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

  void _sendMessage(String message) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc('${widget.driverId}_${widget.passId}')
        .collection('messages')
        .add({
      'sender': 'driver', // or 'user' depending on who sends the message
      'message': message,
      'timestamp': DateTime.now(),
    });

    _messageController.clear();
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
        title: Text(widget.passName),
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
                          message['sender'] == 'driver' ? 'Driver' : 'User',
                        ),
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
