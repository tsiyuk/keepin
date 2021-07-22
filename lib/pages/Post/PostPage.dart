import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Post/LikeCommentShare.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

import '../UserProfileDisplay.dart';

class PostPage extends StatefulWidget {
  final Post post;
  PostPage({required this.post});
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  Widget title = Text("Post Detail");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildPoster(context, widget.post),
            _buildPost(context),
            _buildImages(context, widget.post),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: LikeCommentShare(post: widget.post),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context, Post post) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    return FutureBuilder<UserProfile>(
      future: userProfileProvider.readUserProfile(post.posterId),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ImageButton(
                  image: post.posterAvatarLink == null
                      ? defaultAvatar(50)
                      : Image.network(
                          post.posterAvatarLink!,
                          fit: BoxFit.cover,
                        ),
                  size: 50,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            UserProfileDisplay(post.posterId)));
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextH3(
                      post.posterName,
                      size: 20,
                    ),
                    TextH4(snapshot.data!.bio ?? "")
                  ],
                ),
              ],
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget _buildPost(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.post.text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildImages(BuildContext context, Post post) {
    return Wrap(
      children: post.imageLinks.map((element) {
        return ImageButton(image: Image.network(element), size: 60);
      }).toList(),
    );
  }
}
