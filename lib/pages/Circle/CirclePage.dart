import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CreatePostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';

class CirclePage extends StatefulWidget {
  final CircleInfo? circleInfo;
  final Circle circle;
  CirclePage({required this.circle, this.circleInfo});
  @override
  _CirclePageState createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> with TickerProviderStateMixin {
  User user = FirebaseAuth.instance.currentUser!;
  bool isMember = false;
  bool loading = true;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initCircleInfo(CircleProvider cp) async {
    cp.loadAll(widget.circle, widget.circleInfo);
    bool temp = await cp.isMember(user.uid);
    if (temp && widget.circleInfo == null) {
      CircleInfo circleInfo = await cp.readCircleInfoFromUser();
      cp.loadAll(widget.circle, circleInfo);
    }
    setState(() {
      isMember = temp;
      loading = false;
    });
    cp.addCircleHistory();
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    initCircleInfo(circleProvider);
    Widget _profileSection = Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.network(
              widget.circle.avatarURL,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: ListTile(
              title: TextH2(widget.circle.circleName),
              subtitle: !isMember
                  ? TextH4(
                      'Join the ${widget.circle.circleName} and clock in every day')
                  : TextH4('Clock in days: ${circleProvider.clockinCount}'),
            ),
          ),
        ],
      ),
    );

    BottomAppBar bottomBar = BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        IconButton(
          onPressed: () {},
          iconSize: 30,
          icon: Icon(Icons.menu),
        ),
        IconButton(
          onPressed: () {},
          iconSize: 30,
          icon: Icon(Icons.fireplace_outlined),
        ),
        // BottomBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.lock_clock), label: 'Clock in'),
        // // the clock in may use a floating action button with CircularNotchedRectangle() for better visual effect
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.fireplace_outlined), label: 'Recommend'),
      ]),
    );

    final _postBarItems = <Widget>[
      Tab(text: 'Description'),
      Tab(text: 'Post'),
      Tab(text: 'LeaderBoard'),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: loading
          ? Loading(50)
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade800.withAlpha(0x20),
                  ),
                  child: Column(
                    children: [
                      _profileSection,
                      TabBar(
                        labelColor: Theme.of(context).primaryColorDark,
                        indicatorColor: Theme.of(context).primaryColor,
                        controller: _tabController,
                        tabs: _postBarItems,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Center(
                          child: circleProvider.description != null
                              ? Text(circleProvider.description!)
                              : Text("No Description")),
                      StreamBuilder<List<Post>>(
                          stream: postProvider
                              .readPostsFromCircle(widget.circle.circleName),
                          //stream: postProvider.posts,
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return ListView.separated(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  Post post = snapshot.data![index];
                                  return postDetail(context, post);
                                },
                                separatorBuilder: (c, i) => Container(
                                  height: 10,
                                  color: Colors.blueGrey.shade100,
                                ),
                              );
                            } else {
                              return Text('null');
                            }
                          }),
                      Center(
                        child: Column(children: [
                          PrimaryButton(
                              child: Text('Join the Circle'),
                              onPressed: () {
                                if (isMember) {
                                  showSuccess(context,
                                      'You have been a member of ${circleProvider.circleName}');
                                } else {
                                  circleProvider.joinCircle();
                                  setState(() {
                                    isMember = true;
                                  });
                                }
                              }),
                          PrimaryButton(
                            child: Text('Clock in'),
                            onPressed: () async {
                              try {
                                await circleProvider.clockin();
                              } on FirebaseException catch (e) {
                                showError(context, e.code);
                              }
                            },
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: bottomBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isMember) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreatePostPage(
                    user: user, circleName: widget.circle.circleName)));
          } else {
            showWarning(context,
                'Please join in the circle first and then you can post');
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }
}
