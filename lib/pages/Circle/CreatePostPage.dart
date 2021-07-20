import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';

class CreatePostPage extends StatefulWidget {
  final User user;
  final String circleName;
  const CreatePostPage({Key? key, required this.user, required this.circleName})
      : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  TextEditingController _textController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  bool isUploadCompleted = true;
  @override
  Widget build(BuildContext context) {
    PostProvider postProvider =
        Provider.of<PostProvider>(context, listen: false);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              maxLines: 1,
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              onTap: () {
                postProvider.initPostInfo(
                    widget.user, widget.circleName, circleProvider.tags);
              },
              onEditingComplete: () {
                postProvider.changeTitle(_titleController.text);
              },
            ),
            TextFormField(
              maxLines: 8,
              controller: _textController,
              decoration: InputDecoration(labelText: 'Text'),
              onTap: () {
                postProvider.initPostInfo(
                    widget.user, widget.circleName, circleProvider.tags);
              },
              onEditingComplete: () {
                postProvider.changeText(_textController.text);
              },
            ),
            IconButton(
              iconSize: 60,
              icon: Icon(
                Icons.camera_alt_outlined,
              ),
              onPressed: () async {
                setState(() {
                  isUploadCompleted = false;
                });
                postProvider.initPostInfo(
                    widget.user, widget.circleName, circleProvider.tags);
                await postProvider.uploadAssets(context);
                setState(() {
                  isUploadCompleted = true;
                });
              },
            ),
            PrimaryButton(
                child: Text('Post'),
                onPressed: () async {
                  postProvider.changeTitle(_titleController.text);
                  postProvider.changeText(_textController.text);
                  if (isUploadCompleted) {
                    postProvider.createPost();
                    Navigator.of(context).pop();
                    await circleProvider.addExp(circleProvider.POST_EXP);
                    showSuccess(context, 'Create post!');
                  } else {
                    showWarning(context, 'Please wait for uploading images');
                  }
                }),
          ],
        ),
      ),
    );
  }
}
