import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:keepin/pages/Circle/CreateCirclePage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:provider/provider.dart';

import '../Circle/CirclePage.dart';

class HomePage extends StatelessWidget {
  // to prevent creating multiple HomePage at different time to save memory
  // so only one HomePage. Might change to stateful or use StreamBuilder
  // to render different content
  const HomePage();

  // https://flutter.dev/docs/cookbook/navigation/navigation-basics
  // refer to this link for navigating to circle page and back
  Widget _buildCircleList(BuildContext context) {
    CircleProvider circleProvider = Provider.of<CircleProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircleButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateCirclePage()));
            },
            child: Icon(Icons.add_box, size: 50, color: Colors.teal),
          ),
          _buildCircleButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => CirclePage()));
            },
            child: defaultAvatar(50),
          ),
          _buildCircleButton(
            onPressed: () {},
            child: Container(
              color: Colors.blue.shade700,
            ),
          ),
          _buildCircleButton(
            onPressed: () {},
            child: Container(
              color: Colors.green.shade700,
            ),
          )
          // create circle button,
          // my circles StreamBuilder
        ],
      ),
    );
  }

  Widget _buildCircleButton(
      {required Function() onPressed, required Widget child}) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          child: child,
          width: 50,
          height: 50,
        ),
      ),
      padding: EdgeInsets.all(6),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      minWidth: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCircleList(context),
        Divider(),
        Expanded(child: Feed()),
      ],
    );
  }
}

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          labelColor: Theme.of(context).primaryColorDark,
          indicatorColor: Theme.of(context).primaryColor,
          labelPadding: EdgeInsets.all(12.0),
          controller: _tabController,
          tabs: <Widget>[Text("Follow"), Text("Recommendation")],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildFollowFeed(), _buildRecommendation()],
          ),
        )
      ],
    );
  }

  Widget _buildFollowFeed() {
    return Center(child: Text("follow feed"));
  }

  Widget _buildRecommendation() {
    return Center(child: Text("Recommendation feed"));
  }
}
