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

    Widget _buildMenu() {
      return Column(
        children: [
          circleProvider.isAdmin(user.uid)
              ? ListTile(
                  leading: Icon(Icons.edit),
                  title: TextH3('Edit Description'),
                  onTap: () async {
                    return await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(20.0),
                            actionsPadding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 16.0),
                            content: Description(
                                initDescription: circleProvider.description),
                          );
                        });
                  },
                )
              : SizedBox(),
          circleProvider.isAdmin(user.uid)
              ? ListTile(
                  leading: Icon(Icons.edit),
                  title: TextH3('Edit Tags'),
                  onTap: () async {
                    return await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(20.0),
                            actionsPadding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 16.0),
                            content: _buildTags(context, circleProvider.tags),
                          );
                        });
                  },
                )
              : SizedBox(),
          !isMember
              ? ListTile(
                  leading: Icon(Icons.add),
                  title: TextH3('Join Circle'),
                  onTap: () {
                    circleProvider.joinCircle();
                    setState(() {
                      isMember = true;
                    });
                  },
                )
              : ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: TextH3('Quit Circle'),
                  onTap: () async {
                    try {
                      await circleProvider.quitCircle();
                    } on FirebaseException catch (e) {
                      showError(context, e.code);
                    }
                    setState(() {
                      isMember = false;
                    });
                  },
                )
        ],
      );
    }

    BottomAppBar bottomBar = BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        IconButton(
          tooltip: 'Menu',
          onPressed: () {
            showModalBottomSheet(
                context: context, builder: (context) => _buildMenu());
          },
          iconSize: 30,
          icon: Icon(Icons.menu),
        ),
        IconButton(
          tooltip: 'Clock in',
          onPressed: () async {
            try {
              await circleProvider.clockin();
            } on FirebaseException catch (e) {
              showError(context, e.code);
            }
          },
          iconSize: 30,
          icon: Icon(Icons.lock_clock),
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
                  child: TabBarView(controller: _tabController, children: [
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
                        stream: PostProvider.readPostsFromCircle(
                            widget.circle.circleName),
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
                    Rank(
                      circleName: circleProvider.circleName,
                    ),
                  ]),
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

class Rank extends StatefulWidget {
  final String circleName;
  const Rank({Key? key, required this.circleName}) : super(key: key);

  @override
  _RankState createState() => _RankState();
}

class _RankState extends State<Rank> {
  late Future<List<UserProfile>> list;

  @override
  void initState() {
    list = CircleProvider.readUserInfos(widget.circleName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProfile>>(
      future: list,
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
              return Expanded(
                child: SizedBox(
                  height: 300,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserProfileDisplay(
                                    snapshot.data![index].userId)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: TextH2((index + 1).toString()),
                                  ),
                                  snapshot.data![index].avatarURL != null
                                      ? ClipOval(
                                          child: Image.network(
                                            snapshot.data![index].avatarURL!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : defaultAvatar(40),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child:
                                        TextH3(snapshot.data![index].userName),
                                  ),
                                ]),
                          ),
                        );
                      }),
                ),
              );
            }
        }
      },
    );
  }
}
