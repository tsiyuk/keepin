import 'package:flutter/material.dart';
import 'package:keepin/pages/Message/widget/Messages.dart';
import 'package:keepin/pages/Message/widget/NewMessage.dart';
import 'package:keepin/pages/Message/widget/ProfileHeader.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

class ChatRoomPage extends StatelessWidget {
  final ChatRoom chatRoom;

  const ChatRoomPage({required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    String otherId = ChatRoomAPI.getOtherUserId(chatRoom);
    Future<UserProfile> otherUser =
        UserProfileProvider.readUserProfile(otherId);

    if (ChatRoomAPI.isUnRead(chatRoom)) {
      ChatRoomAPI.readMessage(chatRoom);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).primaryColorLight,
      body: FutureBuilder<UserProfile>(
          future: otherUser,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Loading(50);
              default:
                if (snapshot.hasError) {
                  return Text('Something Went Wrong Try later');
                } else {
                  return SafeArea(
                    child: Column(
                      children: [
                        ProfileHeaderWidget(userProfile: snapshot.data!),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: MessagesWidget(
                              chatRoom: chatRoom,
                              userProfile: snapshot.data!,
                            ),
                          ),
                        ),
                        NewMessageWidget(chatRoom: chatRoom),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}
