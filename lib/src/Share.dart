import 'package:flutter/material.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';

import 'CommonWidgets.dart';
import 'Loading.dart';
import 'models/ChatRoom.dart';
import 'models/UserProfile.dart';

Future<void> share(BuildContext context,
    {String? postId, String? circleName}) async {
  String shared = postId != null ? "post" : "circle";
  return await showDialog(
    context: context,
    builder: (popContext) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(20),
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          width: MediaQuery.of(context).size.width - 20,
          constraints: BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextH2("Share To:"),
              ),
              StreamBuilder<List<ChatRoom>>(
                stream: ChatRoomAPI.getChatRooms(),
                builder: (sContext, snapshot) {
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
                        return Container(
                          width: MediaQuery.of(context).size.width - 20,
                          constraints: BoxConstraints(maxHeight: 400),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: chatRooms.length,
                            separatorBuilder: (lContext, index) =>
                                Divider(thickness: 1),
                            itemBuilder: (lContext, index) {
                              ChatRoom chatRoom = chatRooms[index];
                              String otherId =
                                  ChatRoomAPI.getOtherUserId(chatRooms[index]);
                              return StreamBuilder<UserProfile>(
                                stream: UserProfileProvider.readUserProfile(
                                    otherId),
                                builder: (fContext, snapshot) {
                                  if (snapshot.data != null) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        ChatRoomAPI.createMessage(
                                            chatRoom, "check out this $shared!",
                                            postId: postId,
                                            inviteCircleName: circleName);
                                        Navigator.of(popContext).pop();
                                        showSuccess(context,
                                            "Shared $shared successfully!");
                                      },
                                      child: ListTile(
                                        leading: ImageButton(
                                          imageLink: snapshot.data!.avatarURL!,
                                          size: 40,
                                        ),
                                        title: TextH3(snapshot.data!.userName,
                                            size: 20),
                                      ),
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              );
                            },
                          ),
                        );
                      }
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
