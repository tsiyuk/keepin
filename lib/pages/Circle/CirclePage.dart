import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CreatePostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/Share.dart';
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
  // final bool isMember;
  CirclePage({required this.circle, this.circleInfo});
  @override
  _CirclePageState createState() => _CirclePageState();
}

/// The circle page use rebuild to query circle and circle info, which may cause a lot of read
class _CirclePageState extends State<CirclePage> with TickerProviderStateMixin {
  User user = FirebaseAuth.instance.currentUser!;
  bool isMember = false;
  bool loading = true;
  late TabController _tabController;
  // late num clockInCount;
  // late num exp;
  @override
  void initState() {
    super.initState();
    //isMember = widget.isMember;
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    // clockInCount =
    //     widget.circleInfo != null ? widget.circleInfo!.clockinCount : 0;
    // exp = widget.circleInfo != null ? widget.circleInfo!.exp : 0;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initCircleInfo(CircleProvider cp) async {
    Circle circle =
        await CircleProvider.readCircleFromName(widget.circle.circleName);
    bool temp =
        await CircleProvider.isCurrentUserMember(widget.circle.circleName);
    cp.loadAll(circle);
    if (temp) {
      CircleInfo circleInfo = await cp.readCircleInfoFromUser();
      cp.loadInfo(circleInfo);
    }
    setState(() {
      loading = false;
      isMember = temp;
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
            child: ImageButton(
              imageLink: widget.circle.avatarURL,
              size: 80,
              oval: false,
            ),
          ),
          Expanded(
            child: ListTile(
              title: TextH2(widget.circle.circleName),
              subtitle: !isMember
                  ? TextH4(
                      'Join the ${widget.circle.circleName} and clock in every day')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
      return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
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
                                insetPadding: const EdgeInsets.all(20),
                                content: Description(
                                    initDescription:
                                        circleProvider.description),
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
                                content:
                                    _buildTags(context, circleProvider.tags),
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
          ),
        ),
      );
    }

    BottomAppBar bottomBar = BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => _buildMenu());
            },
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).primaryColorLight,
            ),
            label: TextH3('Menu')),
        // IconButton(
        //   tooltip: 'Menu',
        //   onPressed: () {
        //     showModalBottomSheet(
        //         isScrollControlled: true,
        //         context: context,
        //         builder: (context) => _buildMenu());
        //   },
        //   iconSize: 30,
        //   icon: Icon(Icons.menu),
        // ),
        TextButton.icon(
            onPressed: () async {
              try {
                await circleProvider.clockin();
                showSuccess(context, "Clock in successfully!");
                // setState(() {
                //   exp += circleProvider.CLOCK_IN_EXP;
                //   clockInCount += 1;
                // });
              } on FirebaseException catch (e) {
                showWarning(context, e.code);
              }
            },
            icon: Icon(
              Icons.lock_clock,
              color: Theme.of(context).primaryColorLight,
            ),
            label: TextH3('Clock in')),
        // IconButton(
        //   tooltip: 'Clock in',
        //   onPressed: () async {
        //     try {
        //       await circleProvider.clockin();
        //       // setState(() {
        //       //   exp += circleProvider.CLOCK_IN_EXP;
        //       //   clockInCount += 1;
        //       // });
        //     } on FirebaseException catch (e) {
        //       showWarning(context, e.code);
        //     }
        //   },
        //   iconSize: 30,
        //   icon: Icon(Icons.lock_clock),
        // ),
      ]),
    );

    final _postBarItems = <Widget>[
      Tab(text: 'Description'),
      Tab(text: 'Post'),
      Tab(text: 'LeaderBoard'),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                share(context, circleName: widget.circle.circleName);
              },
              icon: Icon(Icons.share_outlined))
        ],
      ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Text(
                                circleProvider.description ?? "No Description",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Divider(
                              height: 40,
                            ),
                            TextH3("Tags:"),
                            Wrap(
                              children: circleProvider.tags.map((tag) {
                                return Chip(label: Text(tag));
                              }).toList(),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<List<Post>>(
                        stream: PostProvider.readPostsFromCircle(
                            widget.circle.circleName),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return ListView.separated(
                              physics: BouncingScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Post post = snapshot.data![index];
                                return postDetail(context, post);
                              },
                              separatorBuilder: (c, i) => Container(
                                height: 5,
                                color: Colors.blueGrey.shade100,
                              ),
                            );
                          } else {
                            return Text('null');
                          }
                        }),
                    SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Rank(
                        circleName: circleProvider.circleName,
                      ),
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
      mainAxisSize: MainAxisSize.min,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 1000),
        TextFormField(
          maxLines: 8,
          autofocus: true,
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'description',
            filled: true,
            fillColor: Colors.blueGrey.shade50,
          ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: TextH3(snapshot.data![index].userName),
                              ),
                            ]),
                      ),
                    );
                  });
            }
        }
      },
    );
  }
}
