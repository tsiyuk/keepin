import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CreatePostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';

class CirclePage extends StatefulWidget {
  // final Circle circle;
  final CircleInfo circleInfo;
  CirclePage({required this.circleInfo});
  @override
  _CirclePageState createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> with TickerProviderStateMixin {
  User user = FirebaseAuth.instance.currentUser!;
  //late Circle circle;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void initCircle(CircleProvider cp) async {
    //circle = await cp.readCircleFromName(widget.circleInfo.circleName);
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    initCircle(circleProvider);
    //circleProvider.loadAll(circle, widget.circleInfo);
    Widget _profileSection = Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: defaultAvatar(80),
          ),
          Expanded(
            child: ListTile(
              title: TextH2(widget.circleInfo.circleName),
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
        // // TODO
        // // the clock in may use a floating action button with CircularNotchedRectangle() for better visual effect
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.fireplace_outlined), label: 'Recommend'),
      ]),
    );

    final _postBarItems = <Widget>[
      Tab(text: 'Description'),
      Tab(text: 'Post'),
      Tab(text: 'Theme'),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: Column(
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
                Text('1'),
                StreamBuilder<List<Post>>(
                    stream: postProvider
                        .readPostsFromCircle(widget.circleInfo.circleName),
                    //stream: postProvider.posts,
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Image.network(
                                    snapshot.data![index].posterAvatarLink!),
                                // title: Column(
                                //   children: [
                                //     Text(snapshot.data![index].posterName),
                                //     Text(snapshot.data![index].text),
                                //     snapshot.data![index].imageLinks[0] != null
                                //         ? Image.network(
                                //             snapshot.data![index].imageLinks[0])
                                //         : SizedBox(),
                                //   ],
                                // ),
                                title: Text(snapshot.data![index].posterName),
                                subtitle: Text(snapshot.data![index].text),
                                shape: Border.all(),
                              );
                            });
                      } else {
                        return Text('null');
                      }
                    }),
                PrimaryButton(
                    child: Text('Create Post'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CreatePostPage(
                              user: user,
                              circleName: widget.circleInfo.circleName)));
                    }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CreatePostPage(
                  user: user, circleName: widget.circleInfo.circleName)));
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
