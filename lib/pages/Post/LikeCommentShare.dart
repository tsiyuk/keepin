import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Comment.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';

class LikeCommentShare extends StatefulWidget {
  final Post post;
  final bool showComment;
  LikeCommentShare({required this.post, this.showComment = false});
  @override
  _LikeCommentShareState createState() => _LikeCommentShareState();
}

class _LikeCommentShareState extends State<LikeCommentShare> {
  bool hasLiked = false;
  num numOfLikes = 0;
  bool showComment = false;
  Widget comments = SizedBox();

  @override
  void initState() {
    super.initState();
    setState(() {
      showComment = widget.showComment;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initPost(PostProvider postProvider) async {
    //postProvider.loadAll(widget.post);
    final bool temp = await PostProvider.hasLiked(widget.post);
    setState(() {
      hasLiked = temp;
      numOfLikes = widget.post.numOfLikes;
      if (showComment) {
        comments = _buildComment(context, postProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    initPost(postProvider);
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
                text: " comments",
                onPressed: () {
                  setState(() {
                    if (showComment) {
                      comments = SizedBox();
                    } else {
                      comments = _buildComment(context, postProvider);
                    }
                    showComment = !showComment;
                  });
                }),
            StyledButton(
                icon: Icons.share_outlined, text: " share", onPressed: () {})
          ],
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: comments,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              ScaleTransition(child: child, scale: animation),
        )
      ],
    );
  }

  Widget _buildComment(BuildContext context, PostProvider postProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StyledButton(
              icon: Icons.add_rounded,
              text: " add comment",
              onPressed: () {
                showSuccess(context, "hi");
              }),
          StreamBuilder<List<Comment>>(
            stream: PostProvider.getComments(widget.post.postId!),
            initialData: [],
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Loading(50);
                default:
                  if (snapshot.hasError) {
                    showError(context, snapshot.error.toString());
                    return Center(child: Text("Error"));
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Comment comment = snapshot.data![index];
                          return Text.rich(
                            TextSpan(
                              text: comment.commenterName,
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: comment.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                                // can add more TextSpans here...
                              ],
                            ),
                          );
                        });
                  }
              }
            },
          )
        ],
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
