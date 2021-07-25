import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CirclePage.dart';
import 'package:keepin/pages/Post/PostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Message.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';

class MessageWidget extends StatelessWidget {
  static Map<String, Image> map = Map<String, Image>();
  final Message message;
  final UserProfile userProfile;
  final bool isMe;
  const MessageWidget({
    Key? key,
    required this.message,
    required this.userProfile,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        isMe
            ? buildAvatar(FirebaseAuth.instance.currentUser!.photoURL)
            : buildAvatar(userProfile.avatarURL),
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            color:
                isMe ? Colors.grey[100] : Theme.of(context).primaryColorLight,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: TextStyle(color: isMe ? Colors.black : Colors.white),
          ),
          if (message.postId != null)
            FutureBuilder<Post>(
              future: PostProvider.readPost(message.postId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Divider();
                } else if (snapshot.hasData) {
                  Post post = snapshot.data!;
                  return Container(
                    width: 200,
                    height: 70,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(1, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: TextH3(post.title, clip: true),
                      subtitle: TextH5(post.posterName),
                      trailing: TextH5(post.circleName),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PostPage(post: post))),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          if (message.inviteCircleName != null)
            FutureBuilder<Circle>(
              future:
                  CircleProvider.readCircleFromName(message.inviteCircleName!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Circle circle = snapshot.data!;
                  return Container(
                    width: 200,
                    height: 70,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(1, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: ImageButton(
                          imageLink: circle.avatarURL,
                          size: 50,
                          fit: BoxFit.cover,
                          oval: false,
                        ),
                      ),
                      title: TextH3(circle.circleName),
                      subtitle: IconAndDetail(
                          Icons.people, circle.numOfMembers.toString()),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CirclePage(circle: circle))),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
        ],
      );

  Widget buildAvatar(String? url) {
    if (url == null) {
      return defaultAvatar(40);
    } else {
      if (!map.containsKey(url)) {
        map.addEntries([
          MapEntry(
              url,
              Image.network(
                url,
                fit: BoxFit.cover,
              ))
        ]);
      }
      return Container(
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ImageButton(
          image: map[url]!,
          size: 40,
        ),
      );
    }
  }
}
