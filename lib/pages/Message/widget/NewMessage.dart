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
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                focusColor: Theme.of(context).primaryColorLight,
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'Type your message',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0),
                  gapPadding: 4,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) => setState(() {
                message = value;
              }),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: message.trim().isEmpty
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    ChatRoomAPI.createMessage(widget.chatRoom, message);
                    _controller.clear();
                  },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColorLight,
              ),
              child: Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
