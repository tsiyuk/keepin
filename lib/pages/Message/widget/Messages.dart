import 'package:flutter/material.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/Message.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';

import 'Message.dart';

class MessagesWidget extends StatelessWidget {
  final ChatRoom chatRoom;
  final UserProfile userProfile;

  const MessagesWidget({
    Key? key,
    required this.chatRoom,
    required this.userProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var myId = UserState.user!.uid;
    return StreamBuilder<List<Message>>(
      stream: ChatRoomAPI.getMessages(chatRoom.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return buildText('Something Went Wrong Try later');
        } else {
          var messages = snapshot.data;

          return messages == null || messages.isEmpty
              ? buildText('Say Hi..')
              : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return MessageWidget(
                      message: message,
                      isMe: message.userId == myId,
                      userProfile: userProfile,
                    );
                  },
                );
        }
      },
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24),
        ),
      );
}
