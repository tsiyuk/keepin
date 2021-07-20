import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CreatePostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';

import '../TagSelector.dart';
import '../UserProfileDisplay.dart';

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
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    CircleProvider circleProvider = Provider.of<CircleProvider>(context);
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
                  : Column(
                      children: [
                        TextH5('Clock in days: ${circleProvider.clockinCount}'),
                        TextH5('Exp: ${circleProvider.exp}'),
                      ],
                    ),
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
                      Column(
                        children: [
                          Center(
                              child: circleProvider.description != null
                                  ? Text(circleProvider.description!)
                                  : Text("No Description")),
                          circleProvider.isAdmin(user.uid)
                              ? _buildTags(context, circleProvider.tags)
                              : Container(),
                          circleProvider.isAdmin(user.uid)
                              ? Description(
                                  initDescription: circleProvider.description,
                                )
                              : Container(),
                        ],
                      ),
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
                          ),
                          _buildRanks(context),
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

  Widget _buildTags(BuildContext context, List<String> tags) {
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    List<String> temp = circleProvider.tags;
    return Column(
      children: [
        TagSelector(texts: temp),
        PrimaryButton(
          child: Text('Save Tags'),
          onPressed: () {
            circleProvider.setTags(temp);
          },
        )
      ],
    );
  }

  Widget _buildRanks(BuildContext context) {
    CircleProvider circleProvider = Provider.of<CircleProvider>(context);
    return Expanded(
      child: FutureBuilder<List<UserProfile>>(
        future: circleProvider.readUserRank(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: Loading(20.0));
            default:
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.length == 0) {
                return Container(
                  color: Theme.of(context).accentColor,
                  alignment: Alignment.center,
                  child: Text(
                    'Error',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                );
              } else {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserProfileDisplay(
                                    snapshot.data![index].userId)));
                          },
                          child: Row(children: [
                            TextH1(index.toString()),
                            ListTile(
                              leading: snapshot.data![index].avatarURL != null
                                  ? ClipOval(
                                      child: Image.network(
                                        snapshot.data![index].avatarURL!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : defaultAvatar(40),
                              title: TextH3(snapshot.data![index].userName),
                            ),
                          ]));
                    });
              }
          }
        },
      ),
    );
  }
}

class Description extends StatefulWidget {
  final String? initDescription;
  const Description({Key? key, this.initDescription}) : super(key: key);

  @override
  _DescriptionState createState() => _DescriptionState(initDescription);
}

class _DescriptionState extends State<Description> {
  final String? text;
  late final TextEditingController descriptionController;
  _DescriptionState(this.text);
  @override
  void initState() {
    descriptionController = TextEditingController(text: text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CircleProvider circleProvider = Provider.of<CircleProvider>(context);
    return Column(
      children: [
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: 'description'),
          validator: validator("description"),
        ),
        SecondaryButton(
            child: Text('Save Description'),
            onPressed: () {
              circleProvider.setDescritpion(descriptionController.text);
            })
      ],
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
