import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:provider/provider.dart';

class CreateCirclePage extends StatefulWidget {
  const CreateCirclePage({Key? key}) : super(key: key);

  @override
  _CreateCirclePageState createState() => _CreateCirclePageState();
}

class _CreateCirclePageState extends State<CreateCirclePage> {
  final _textController = TextEditingController();
  final _tagsController = TextEditingController();
  final tags = <String>[];
  @override
  Widget build(BuildContext context) {
    CircleProvider circleProvider = Provider.of<CircleProvider>(context);
    return Column(
      children: [
        Material(
          child: TextFormField(
            controller: _textController,
            decoration: InputDecoration(labelText: 'circleName'),
          ),
        ),
        Material(
          child: TextFormField(
            controller: _tagsController,
            decoration: InputDecoration(labelText: 'tag'),
            onEditingComplete: () {
              setState(() {
                tags.add(_tagsController.text);
              });
            },
          ),
        ),
        PrimaryButton(
            child: Text('upload pictures'),
            onPressed: () async {
              circleProvider.uploadAvatar(context);
            }),
        PrimaryButton(
            child: Text('Create Circle'),
            onPressed: () {
              circleProvider.createCircle(_textController.text, tags, true);
              Navigator.of(context).pop();
            }),
      ],
    );
  }
}
