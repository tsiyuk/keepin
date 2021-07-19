import 'package:flutter/material.dart';
import 'package:keepin/pages/TagSelector.dart';
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
  final tags = <String>[];
  final double _avatarSize = 120;
  bool isPublic = true;
  Image? _avatar;

  void handleCreateCircle(CircleProvider circleProvider) async {
    try {
      String name = _textController.text;
      if (_avatar == null) {
        showWarning(context, "Please upload an image for circle profile.");
        return;
      } else if (name.isEmpty || name.trim().length == 0) {
        showWarning(context, "Please enter a valid circle name");
        return;
      }
      await circleProvider.createCircle(name, tags, isPublic);
      showSuccess(context, "Circle $name is successfully created!");
      Navigator.of(context).pop();
      // should go in to the circle
    } catch (e) {
      String str = "Fail to create circle:\n";
      showError(context, str + e.toString());
    }
  }

  void handleUpload(CircleProvider circleProvider) async {
    try {
      Image avatar = Image.file(
        await circleProvider.uploadAvatar(context),
        fit: BoxFit.cover,
      );
      setState(() {
        this._avatar = avatar;
      });
    } catch (e) {
      showWarning(context, "Failed to add image!");
    }
  }

  @override
  Widget build(BuildContext context) {
    CircleProvider circleProvider = Provider.of<CircleProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(44.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UploadImageButton(
              image: _avatar == null ? defaultAvatar(_avatarSize) : _avatar!,
              size: _avatarSize,
              onPressed: () {
                handleUpload(circleProvider);
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'circleName'),
            ),
            // TextFormField(
            //   controller: _tagsController,
            //   decoration: InputDecoration(labelText: 'tag'),
            //   onEditingComplete: () {
            //     setState(() {
            //       tags.add(_tagsController.text);
            //     });
            //   },
            // ),

            // tag selector
            TagSelector(texts: tags),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SwitchListTile(
                title: TextH3("public", size: 22),
                subtitle: isPublic
                    ? TextH4("everyone can view the post")
                    : TextH4("only invited members can view the post"),
                contentPadding: const EdgeInsets.all(10.0),
                tileColor: Colors.blueGrey.shade50,
                activeColor: Colors.teal.shade400,
                value: isPublic,
                onChanged: (value) {
                  setState(() {
                    isPublic = value;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SecondaryButton(
                  child: Text("Cancel"),
                  onPressed: Navigator.of(context).pop,
                ),
                PrimaryButton(
                  child: Text('Create Circle'),
                  onPressed: () {
                    handleCreateCircle(circleProvider);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
