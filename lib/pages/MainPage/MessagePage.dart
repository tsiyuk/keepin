import 'package:flutter/material.dart';
import 'package:keepin/pages/Message/ChatRoomPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    ChatRoomProvider chatRoomProvider = Provider.of<ChatRoomProvider>(context);
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    return StreamBuilder<List<ChatRoom>>(
        stream: chatRoomProvider.chatRooms,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Loading(50);
            default:
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text("Error");
              } else {
                var chatRooms = snapshot.data!;
                if (chatRooms.isEmpty) {
                  return Text("Start a conversation");
                } else {
                  return ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        String otherId =
                            chatRoomProvider.getOtherUserId(chatRooms[index]);
                        return FutureBuilder<UserProfile>(
                            future:
                                userProfileProvider.readUserProfile(otherId),
                            builder: (context, snapshot) {
                              return GestureDetector(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        child: buildAvatar(
                                            snapshot.data!.avatarURL!),
                                      ),
                                      Column(
                                        children: [
                                          Text(snapshot.data!.userName),
                                          chatRooms[index].latestMessage == null
                                              ? Text('')
                                              : Text(chatRooms[index]
                                                  .latestMessage!
                                                  .text),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ChatRoomPage(
                                              chatRoom: chatRooms[index]))));
                            });
                      });
                }
              }
          }
        });
  }

  Widget buildAvatar(String? url) {
    if (url == null) {
      return defaultAvatar(16);
    } else {
      return CircleAvatar(radius: 16, backgroundImage: NetworkImage(url));
    }
  }
}
