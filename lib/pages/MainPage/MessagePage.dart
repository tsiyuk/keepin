import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Message/ChatRoomPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/Message.dart';
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
                showError(context, snapshot.error.toString());
                return Center(child: Text("Error"));
              } else {
                var chatRooms = snapshot.data!;
                if (chatRooms.isEmpty) {
                  return Center(child: Text("Start a conversation"));
                } else {
                  return ListView.separated(
                      itemCount: chatRooms.length,
                      separatorBuilder: (context, index) => Divider(
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                      itemBuilder: (context, index) {
                        String otherId =
                            chatRoomProvider.getOtherUserId(chatRooms[index]);
                        bool unRead =
                            chatRoomProvider.isUnRead(chatRooms[index]);
                        return FutureBuilder<UserProfile>(
                            future:
                                userProfileProvider.readUserProfile(otherId),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return GestureDetector(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        ImageButton(
                                          image: Image.network(
                                              snapshot.data!.avatarURL!,
                                              fit: BoxFit.cover),
                                          size: 50,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextH2(snapshot.data!.userName),
                                            showLastMessage(
                                                chatRooms[index].latestMessage,
                                                unRead),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ChatRoomPage(
                                              chatRoom: chatRooms[index]))),
                                );
                              } else {
                                return SizedBox();
                              }
                            });
                      });
                }
              }
          }
        });
  }

  Widget showLastMessage(Message? latestMessage, bool unRead) {
    return latestMessage == null
        ? Text('')
        : Text(
            latestMessage.text,
            style: TextStyle(color: unRead ? Colors.red : Colors.black),
          );
  }
}
