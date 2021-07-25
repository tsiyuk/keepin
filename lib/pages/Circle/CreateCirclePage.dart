import 'package:flutter/material.dart';
import 'package:keepin/pages/TagSelector.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:provider/provider.dart';

import 'CirclePage.dart';

class CreateCirclePage extends StatefulWidget {
  const CreateCirclePage({Key? key}) : super(key: key);

  @override
  _CreateCirclePageState createState() => _CreateCirclePageState();
}

class _CreateCirclePageState extends State<CreateCirclePage> {
  final _textController = TextEditingController();
  final _descriptionController = TextEditingController();
  final tags = <String>[];
  final double _avatarSize = 120;
  bool isPublic = true;
  Image? _avatar;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void handleCreateCircle(CircleProvider circleProvider) async {
    try {
      String name = _textController.text;
      String description = _descriptionController.text;
      _formKey.currentState!.save();

      if (_avatar == null) {
        showWarning(context, "Please upload an image for circle profile.");
        return;
      } else if (_formKey.currentState!.validate()) {
        Circle circle = await circleProvider.createCircle(
            name, tags, description, isPublic);
        circleProvider.setDescritpion(description);
        showSuccess(context, "Circle $name is successfully created!");
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CirclePage(
                      circle: circle,
                    )));
        // should go in to the circle
      }
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
    // Color fill = Theme.of(context).primaryColorLight.withOpacity(0.1);
    Color fill = Colors.white;
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: Text("Create Circle", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 30),
                UploadImageButton(
                  image:
                      _avatar == null ? defaultAvatar(_avatarSize) : _avatar!,
                  size: _avatarSize,
                  onPressed: () {
                    handleUpload(circleProvider);
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _textController,
                  decoration: InputDecoration(labelText: 'circleName'),
                  validator: validator("circle name"),
                ),
                SizedBox(height: 16),
                TextFormField(
                  maxLines: 4,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'description',
                    filled: true,
                    fillColor: fill,
                  ),
                  validator: validator("description"),
                ),
                SizedBox(height: 16),
                Container(
                  child: TagSelector(texts: tags),
                  padding: const EdgeInsets.all(12),
                  width: 500,
                  decoration: BoxDecoration(color: fill),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: SwitchListTile(
                    title: TextH3("public", size: 22),
                    subtitle: isPublic
                        ? TextH4("everyone can view the post")
                        : TextH4("only invited members can view the post"),
                    contentPadding: const EdgeInsets.all(10.0),
                    tileColor: fill,
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
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? Function(String?) validator(String field) {
    return (String? value) {
      return value == null || value.isEmpty
          ? "Please enter your $field."
          : null;
    };
  }
}
