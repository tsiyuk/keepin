import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
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
  @override
  Widget build(BuildContext context) {
    PostProvider postProvider =
        Provider.of<PostProvider>(context, listen: false);
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
                postProvider.initPostInfo(widget.user, widget.circleName);
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
                postProvider.initPostInfo(widget.user, widget.circleName);
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
                postProvider.initPostInfo(widget.user, widget.circleName);
                await postProvider.uploadAssets(context);
              },
            ),
            PrimaryButton(
                child: Text('Post'),
                onPressed: () {
                  //postProvider.initPostInfo(widget.user, widget.circleName);
                  postProvider.changeTitle(_titleController.text);
                  postProvider.changeText(_textController.text);
                  postProvider.createPost();
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
    );
  }
}
