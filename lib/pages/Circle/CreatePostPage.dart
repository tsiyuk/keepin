import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Utils.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
  List<File> imageFiles = [];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider =
        Provider.of<PostProvider>(context, listen: false);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    postProvider.initPostInfo(
        widget.user, widget.circleName, circleProvider.tags);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                maxLines: 1,
                controller: _titleController,
                validator: validator("Title"),
                decoration: InputDecoration(labelText: 'Title'),
                onEditingComplete: () {
                  postProvider.changeTitle(_titleController.text);
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                maxLines: 4,
                controller: _textController,
                validator: validator("Post"),
                decoration: InputDecoration(
                  labelText: 'Text',
                  filled: true,
                  fillColor: Colors.blueGrey.shade50,
                ),
                onEditingComplete: () {
                  postProvider.changeText(_textController.text);
                },
              ),
              Wrap(),
              IconButton(
                iconSize: 60,
                icon: Icon(Icons.camera_rounded),
                onPressed: () async {
                  final List<AssetEntity>? assets =
                      await AssetPicker.pickAssets(context, maxAssets: 9);
                  if (assets != null) {
                    for (AssetEntity asset in assets) {
                      if (await asset.exists) {
                        File? file = await Utils.compress(await asset.file);
                        if (file != null && imageFiles.length < 10) {
                          imageFiles.add(file);
                        }
                      }
                    }
                  }
                },
              ),
              PrimaryButton(
                child: Text('Post'),
                onPressed: () async {
                  _formKey.currentState!.save();
                  if (_formKey.currentState!.validate()) {
                    postProvider.changeTitle(_titleController.text);
                    postProvider.changeText(_textController.text);
                    await postProvider.uploadAssets(imageFiles);
                    postProvider.createPost();
                    Navigator.of(context).pop();
                    await circleProvider.addExp(circleProvider.POST_EXP);
                    showSuccess(context, 'Created post!');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? Function(String?) validator(String field) {
    return (String? value) {
      return value == null || value.isEmpty ? "$field cannot be empty" : null;
    };
  }
}
