import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:keepin/src/models/Tag.dart';
import 'package:keepin/src/services/TagProvider.dart';

class TagSelector extends StatefulWidget {
  final List<String> texts;
  TagSelector({Key? key, required this.texts}) : super(key: key);

  @override
  _TagSelectorState createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  List<Tag> _items = [];
  double _fontSize = 18;

  @override
  void initState() {
    super.initState();
    getList();
  }

  void getList() async {
    List<Tag> temp = await TagProvider.readTags();
    setState(() {
      _items = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tags(
      key: _tagStateKey,
      textField: TagsTextField(
        lowerCase: true,
        textStyle: TextStyle(fontSize: _fontSize),
        hintText: 'Or add a new tag',
        autofocus: false,
        onSubmitted: (String str) {
          // Add item to the data source.
          TagProvider.addTag(str);
          setState(() {
            _items.add(Tag(str, 0));
          });
        },
      ),
      itemCount: _items.length, // required
      itemBuilder: (int index) {
        final item = _items[index];

        return ItemTags(
          // Each ItemTags must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(index.toString()),
          index: index, // required
          title: item.tag,
          active: !widget.texts.contains(item.tag),
          activeColor: Colors.blueGrey.shade100,
          textStyle: TextStyle(
            fontSize: _fontSize,
          ),
          combine: ItemTagsCombine.withTextBefore,
          onPressed: (item) {
            setState(() {
              if (item.active!) {
                widget.texts.remove(item.title!);
              } else {
                widget.texts.add(item.title!);
              }
            });
          },
        );
      },
    );
  }

  final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
// Allows you to get a list of all the ItemTags
  _getAllItem() {
    List<Item>? lst = _tagStateKey.currentState?.getAllItem;
    if (lst != null)
      lst.where((a) => a.active == true).forEach((a) => print(a.title));
  }
}
