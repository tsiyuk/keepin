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
  bool hasLiked = false;
  num numOfLikes = 0;

  @override
  void initState() {
    numOfLikes = widget.post.numOfLikes;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    initPost();
    return Container(
      child: Row(
        children: [
          hasLiked
              ? TextButton(
                  style: TextButton.styleFrom(primary: Colors.pinkAccent),
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.favorite),
                        Text(numOfLikes.toString())
                      ],
                    ),
                  ),
                  onPressed: () {
                    postProvider.unlikeViaPost(widget.post);
                    setState(() {
                      hasLiked = false;
                      numOfLikes = numOfLikes - 1;
                    });
                  },
                )
              : TextButton(
                  style: TextButton.styleFrom(primary: Colors.grey),
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border_rounded),
                        Text(numOfLikes.toString())
                      ],
                    ),
                  ),
                  onPressed: () {
                    postProvider.likeViaPost(widget.post);
                    setState(() {
                      hasLiked = true;
                      numOfLikes = numOfLikes + 1;
                    });
                  },
                )
        ],
      ),
    );
  }
}
