import 'package:flutter/material.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';

class LikeCommentShare extends StatefulWidget {
  final Post post;
  LikeCommentShare({required this.post});
  @override
  _LikeCommentShareState createState() => _LikeCommentShareState();
}

class _LikeCommentShareState extends State<LikeCommentShare> {
  final double iconSize = 20;
  bool hasLiked = false;
  num numOfLikes = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initPost() async {
    //postProvider.loadAll(widget.post);
    final bool temp = await PostProvider.hasLiked(widget.post);
    setState(() {
      hasLiked = temp;
      numOfLikes = widget.post.numOfLikes;
    });
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    initPost();
    return Container(
      child: Row(
        children: [
          TextButton(
            style: TextButton.styleFrom(primary: Colors.grey),
            child: Container(
              child: Row(
                children: [
                  hasLiked
                      ? Icon(Icons.favorite_rounded,
                          color: Colors.red.shade200, size: iconSize)
                      : Icon(Icons.favorite_border_rounded, size: iconSize),
                  Text(" " + numOfLikes.toString())
                ],
              ),
            ),
            onPressed: () {
              if (hasLiked) {
                postProvider.unlikeViaPost(widget.post);
              } else {
                postProvider.likeViaPost(widget.post);
              }
            },
          ),
          TextButton(
            style: TextButton.styleFrom(primary: Colors.grey),
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.messenger_outline_rounded, size: iconSize),
                  Text(" comment")
                ],
              ),
            ),
            onPressed: () {},
          ),
          TextButton(
            style: TextButton.styleFrom(primary: Colors.grey),
            child: Container(
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: iconSize),
                  Text(" share")
                ],
              ),
            ),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
