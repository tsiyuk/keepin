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
  @override
  Widget build(BuildContext context) {
    PostProvider postProvider =
        Provider.of<PostProvider>(context, listen: false);
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            child: TextFormField(
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
          ),
          IconButton(
              icon: Icon(Icons.camera_alt_outlined, size: 50,),
              onPressed: () async {
                postProvider.initPostInfo(widget.user, widget.circleName);
                await postProvider.uploadAssets(context);
              },
          ),
          PrimaryButton(
              child: Text('Post'),
              onPressed: () {
                //postProvider.initPostInfo(widget.user, widget.circleName);
                postProvider.changeText(_textController.text);
                postProvider.createPost();
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }
}
