import 'package:flutter/material.dart';
import 'package:keepin/pages/Message/widget/Messages.dart';
import 'package:keepin/pages/Message/widget/NewMessage.dart';
import 'package:keepin/pages/Message/widget/ProfileHeader.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

class ChatRoomPage extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomPage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late ChatRoomProvider chatRoomProvider;
  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    chatRoomProvider = Provider.of<ChatRoomProvider>(context);
    chatRoomProvider.loadAll(widget.chatRoom);
    String otherId = chatRoomProvider.getOtherUserId(widget.chatRoom);
    Future<UserProfile> otherUser =
        userProfileProvider.readUserProfile(otherId);

    if (chatRoomProvider.isUnRead(widget.chatRoom)) {
      chatRoomProvider.readMessage();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).primaryColorLight,
      body: FutureBuilder<UserProfile>(
          future: otherUser,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text("yo");
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
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: MessagesWidget(
                              chatRoom: widget.chatRoom,
                              userProfile: snapshot.data!,
                            ),
                          ),
                        ),
                        NewMessageWidget(chatRoom: widget.chatRoom),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }

  @override
  void dispose() {
    chatRoomProvider.clear();
    super.dispose();
  }
}
