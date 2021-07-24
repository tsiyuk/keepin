import 'package:firebase_auth/firebase_auth.dart';
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
  static const double safePadding = 14;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          _buildDeleteButton(context, widget.post),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: safePadding),
          child: Column(
            children: [
              _buildPoster(context, widget.post),
              _buildPost(context),
              _buildImages(context, widget.post),
              LikeCommentShare(post: widget.post, showComment: true),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context, Post post) {
    return FutureBuilder<UserProfile>(
      future: UserProfileProvider.readUserProfile(post.posterId),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ImageButton(
                  imageLink: post.posterAvatarLink!,
                  size: 50,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            UserProfileDisplay(post.posterId)));
                  },
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextH3(post.posterName, size: 22),
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
    return Container(
      width: MediaQuery.of(context).size.width - safePadding * 2,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 12),
      child: Text(
        widget.post.text,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildImages(BuildContext context, Post post) {
    double spacing = 10;
    double imageSize =
        (MediaQuery.of(context).size.width - safePadding * 2) / 3 - spacing;
    return Wrap(
      spacing: spacing,
      children: post.imageLinks.map((element) {
        return ImageButton(
          imageLink: element,
          size: imageSize,
          oval: false,
        );
      }).toList(),
    );
  }

  Widget _buildDeleteButton(BuildContext buildContext, Post post) {
    return FirebaseAuth.instance.currentUser!.uid == post.posterId
        ? IconButton(
            onPressed: () async {
              await showDialog<bool>(
                  context: buildContext,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                          "Are you sure that you want to delete the post?"),
                      actions: [
                        SecondaryButton(
                            child: Text("cancel"),
                            onPressed: Navigator.of(context).pop),
                        PrimaryButton(
                            child: Text("Save"),
                            onPressed: () {
                              PostProvider.deletePost(post.postId!);
                              Navigator.of(context).pop();
                              Navigator.of(buildContext).pop();
                              showSuccess(context, 'Post has been deleted');
                            })
                      ],
                    );
                  });
            },
            icon: Icon(Icons.delete))
        : SizedBox();
  }
}
