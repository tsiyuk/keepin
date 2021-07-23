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
  late final commentStream;
  bool hasLiked = false;
  num numOfLikes = 0;
  bool showComment = false;
  Widget comments = SizedBox();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    commentStream = PostProvider.getComments(widget.post.postId!);
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

  void initPost() async {
    //postProvider.loadAll(widget.post);
    final bool temp = await PostProvider.hasLiked(widget.post);
    setState(() {
      hasLiked = temp;
      numOfLikes = widget.post.numOfLikes;
      if (showComment) {
        comments = _buildComment(context, commentStream);
      }
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
                text: " comments",
                onPressed: () {
                  setState(() {
                    if (showComment) {
                      comments = SizedBox();
                    } else {
                      comments = _buildComment(context, commentStream);
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
              ScaleTransition(
                  child: child, scale: animation, alignment: Alignment(0, -1)),
        )
      ],
    );
  }

  Widget _buildComment(BuildContext context, Stream<List<Comment>> stream) {
    TextStyle userNameStyle = TextStyle(
      fontSize: 14,
      decoration: TextDecoration.underline,
      color: Colors.blue,
    );
    TextStyle textStyle = TextStyle(
      fontSize: 14,
      decoration: TextDecoration.none,
      color: Colors.black54,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(top: 0, left: 12, right: 12, bottom: 16),
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
                _addCommentForm(context);
              }),
          StreamBuilder<List<Comment>>(
            stream: stream,
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
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Comment comment = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              _addCommentForm(context, comment.commenterName,
                                  comment.commenterId);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text.rich(
                                TextSpan(
                                  text: comment.commenterName + ":",
                                  style: userNameStyle,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: comment.replyTo != null
                                          ? " reply to "
                                          : "",
                                      style: textStyle,
                                    ),
                                    TextSpan(
                                      text: comment.replyTo,
                                      style: userNameStyle,
                                    ),
                                    TextSpan(
                                      text: " " + comment.text,
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              ),
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

  Future<void> _addCommentForm(BuildContext context,
      [replyTo, replyToId]) async {
    return await showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: const EdgeInsets.all(16.0),
          content: Container(
            width: 1000,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextH2(replyTo != null ? "Reply to " + replyTo : "Comment"),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      maxLines: 3,
                      controller: commentController,
                      validator: validator("Comment"),
                      decoration: InputDecoration(
                        focusColor: Theme.of(context).primaryColorLight,
                        hintText: 'comment now!',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ),
                ]),
          ),
          actions: [
            SecondaryButton(
                child: Text("cancel"), onPressed: Navigator.of(context).pop),
            PrimaryButton(
                child: Text("Save"),
                onPressed: () {
                  _formKey.currentState!.save();
                  if (_formKey.currentState!.validate()) {
                    PostProvider.addComments(widget.post.postId!,
                        commentController.text, replyTo, replyToId);
                    Navigator.of(context).pop();
                  }
                })
          ],
        );
      },
    );
  }

  String? Function(String?) validator(String field) {
    return (String? value) {
      return value == null || value.isEmpty ? "$field cannot be empty" : null;
    };
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
