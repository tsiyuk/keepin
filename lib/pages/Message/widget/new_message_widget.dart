import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:provider/provider.dart';

class NewMessageWidget extends StatefulWidget {
  final ChatRoom chatRoom;

  const NewMessageWidget({
    required this.chatRoom,
    Key? key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';

  @override
  Widget build(BuildContext context) {
    ChatRoomProvider chatRoomProvider = Provider.of<ChatRoomProvider>(context);
    chatRoomProvider.loadAll(widget.chatRoom);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                labelText: 'Type your message',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0),
                  gapPadding: 10,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) => setState(() {
                message = value;
              }),
            ),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: message.trim().isEmpty
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    chatRoomProvider.createMessage(message);
                    _controller.clear();
                  },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
