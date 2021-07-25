import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Message/ChatRoomPage.dart';
import 'package:keepin/pages/Post/PostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/Comment.dart';
import 'package:keepin/src/models/Message.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

import '../UserProfileDisplay.dart';

class MessagePage extends StatefulWidget {
  final String userId;
  const MessagePage(this.userId, {Key? key}) : super(key: key);

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
              _buildChatRooms(context),
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

  Widget _buildChatRooms(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: StreamBuilder<List<ChatRoom>>(
          stream: ChatRoomAPI.getChatRooms(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Loading(50);
              default:
                if (snapshot.hasError) {
                  showError(context, snapshot.error.toString());
                  return Center(child: Text("Error"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Start a conversation"));
                } else {
                  var chatRooms = snapshot.data!;
                  return ListView.separated(
                    physics: BouncingScrollPhysics(),
                    itemCount: chatRooms.length,
                    separatorBuilder: (context, index) => Divider(thickness: 1),
                    itemBuilder: (context, index) {
                      String otherId =
                          ChatRoomAPI.getOtherUserId(chatRooms[index]);
                      bool unRead = ChatRoomAPI.isUnRead(chatRooms[index]);
                      return FutureBuilder<UserProfile>(
                          future: UserProfileProvider.readUserProfile(otherId),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              UserProfile userProfile = snapshot.data!;
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(
                                            chatRoom: chatRooms[index]))),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 12.0),
                                      child: ImageButton(
                                          imageLink: userProfile.avatarURL!,
                                          size: 50,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserProfileDisplay(
                                                            userProfile
                                                                .userId)));
                                          }),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextH3(userProfile.userName, size: 20),
                                        showLastMessage(
                                            chatRooms[index].latestMessage,
                                            unRead),
                                      ],
                                    ),
                                  ],
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
          }),
    );
  }

  Widget _buildComments(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: PostProvider.readAllCommentsFromUser(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
          return ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Comment comment = snapshot.data![index];
                return ListTile(
                  // leading: ImageButton(
                  //   imageLink: comment.post!.posterAvatarLink,
                  //   size: 40,
                  // ),
                  title: TextH3(comment.commenterName),
                  subtitle: Text(
                    "commented:  " + comment.text,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _trailing(
                    comment.post!.title,
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostPage(post: comment.post!))),
                );
              });
        } else {
          return Center(child: TextH3('No Comments yet. Start making a post!'));
        }
      },
    );
  }

  Widget _buildLikes(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PostProvider.readAllLikesFromUser(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
          return ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> likeData = snapshot.data![index];
                return ListTile(
                  title: TextH3(likeData["userName"]),
                  subtitle: Text("liked your post!"),
                  trailing: _trailing(likeData["post"].title),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostPage(post: likeData["post"]))),
                );
              });
        } else {
          return Center(child: TextH3('No Likes yet. Start making a post!'));
        }
      },
    );
  }

  Widget _trailing(String text) {
    return Container(
        constraints: BoxConstraints(maxWidth: 100),
        child: Text(
          text,
          textAlign: TextAlign.end,
        ));
  }
}
