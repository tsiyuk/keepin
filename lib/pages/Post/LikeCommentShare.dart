import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
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
  bool showComment = false;

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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            StyledButton(
                icon: hasLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                text: " " + numOfLikes.toString(),
                onPressed: () {
                  if (hasLiked) {
                    postProvider.unlikeViaPost(widget.post);
                  } else {
                    postProvider.likeViaPost(widget.post);
                  }
                },
                red: hasLiked),
            StyledButton(
                icon: Icons.messenger_outline_rounded,
                text: " comment",
                onPressed: () {
                  setState(() {
                    showComment = !showComment;
                  });
                }),
            StyledButton(
                icon: Icons.share_outlined, text: " share", onPressed: () {})
          ],
        ),
        showComment ? _buildComment() : SizedBox()
      ],
    );
  }

  Widget _buildComment() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [Text("comment")],
      ),
    );
  }
}

class StyledButton extends StatelessWidget {
  const StyledButton(
      {required this.icon,
      required this.text,
      required this.onPressed,
      this.red = false});

  final IconData icon;
  final String text;
  final onPressed;
  final bool red;
  final double iconSize = 20;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(primary: Colors.grey),
      child: Container(
        child: Row(
          children: [
            Icon(icon,
                color: red ? Colors.red.shade200 : Colors.grey, size: iconSize),
            Text(text)
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
