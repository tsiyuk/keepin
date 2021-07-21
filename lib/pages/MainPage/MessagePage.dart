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

class _MessagePageState extends State<MessagePage>
    with TickerProviderStateMixin {
  final double iconSize = 40;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          labelColor: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          labelPadding: EdgeInsets.all(12.0),
          controller: _tabController,
          tabs: <Widget>[
            Column(
              children: [
                Icon(Icons.people_alt_rounded,
                    size: iconSize, color: Colors.blue.shade200),
                Text("Messages")
              ],
            ),
            Column(
              children: [
                Icon(Icons.chat_rounded,
                    size: iconSize, color: Colors.green.shade200),
                Text("Comments")
              ],
            ),
            Column(
              children: [
                Icon(Icons.favorite_rounded,
                    size: iconSize, color: Colors.red.shade200),
                Text("Likes")
              ],
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMessages(context),
              _buildComments(context),
              _buildLikes(context),
            ],
          ),
        )
      ],
    );
  }

  Widget showLastMessage(Message? latestMessage, bool unRead) {
    return latestMessage == null
        ? Text('')
        : Text(
            latestMessage.text,
            style: TextStyle(color: unRead ? Colors.red : Colors.black),
          );
  }

  Widget _buildMessages(BuildContext context) {
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
                      bool unRead = chatRoomProvider.isUnRead(chatRooms[index]);
                      return FutureBuilder<UserProfile>(
                          future: userProfileProvider.readUserProfile(otherId),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(
                                            chatRoom: chatRooms[index]))),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
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
                                          TextH3(snapshot.data!.userName,
                                              size: 20),
                                          showLastMessage(
                                              chatRooms[index].latestMessage,
                                              unRead),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          });
                    },
                  );
                }
              }
          }
        });
  }

  Widget _buildComments(BuildContext context) {
    return Center(child: Text("Comments"));
  }

  Widget _buildLikes(BuildContext context) {
    return Center(child: Text("Likes"));
  }
}
