import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:keepin/pages/Circle/CreateCirclePage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
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
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircleButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateCirclePage()));
            },
            child: Icon(Icons.add_box,
                size: 50, color: Theme.of(context).primaryColorLight),
          ),
          VerticalDivider(
            thickness: 1,
          ),
          Container(
            width: MediaQuery.of(context).size.width - 100,
            child: StreamBuilder<List<CircleInfo>>(
              stream: userProfileProvider.circlesJoined,
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  return Container(
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        CircleInfo data = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _buildCircleButton(
                            onPressed: () async {
                              Circle circle =
                                  await CircleProvider.readCircleFromName(
                                      data.circleName);
                              circleProvider.addCircleHistory(circle);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CirclePage(
                                          circle: circle,
                                          circleInfo: data,
                                        )),
                              );
                            },
                            child: Image.network(data.avatarURL,
                                fit: BoxFit.cover),
                          ),
                        );
                      },
                      separatorBuilder: (c, i) => SizedBox(
                        width: 6.0,
                      ),
                    ),
                  );
                } else {
                  return Text('No circles joined');
                }
              },
            ),
          ),
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
          labelPadding: EdgeInsets.all(8.0),
          controller: _tabController,
          tabs: <Widget>[Text("Follow"), Text("Recommendation")],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFollowFeed(context),
              _buildRecommendation(context)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFollowFeed(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return FutureBuilder<List<Post>>(
        initialData: [],
        future: PostProvider.readFollowPosts(
            FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading(40);
          } else {
            if (snapshot.data == null || snapshot.data == []) {
              return TextH3("Join a new circle");
            }
            if (snapshot.data!.length > 0) {
              return ListView.separated(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Post post = snapshot.data![index];
                  userProfileProvider.updatePosterInfo(post);
                  return postDetail(context, post);
                },
                separatorBuilder: (c, i) => Container(
                  height: 5,
                  color: Colors.blueGrey.shade100,
                ),
              );
            } else {
              return Center(child: Text('No posts'));
            }
          }
        });
  }

  Widget _buildRecommendation(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    initUser(context);
    return userProfileProvider.tags.isEmpty
        ? Container(
            child: Text('Please add your favourite tags in Discover'),
          )
        : StreamBuilder<List<Post>>(
            initialData: [],
            stream: userProfileProvider.recommandPost,
            builder: (context, snapshot) {
              if (snapshot.data == [] ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Loading(40);
              }
              if (snapshot.data != null) {
                return ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Post post = snapshot.data![index];
                    userProfileProvider.updatePosterInfo(post);
                    return postDetail(context, post);
                  },
                  separatorBuilder: (c, i) => Container(
                    height: 5,
                    color: Colors.blueGrey.shade100,
                  ),
                );
              } else {
                return Center(child: Text('No recommand posts'));
              }
            });
  }

  void initUser(BuildContext context) async {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    final UserProfile userProfile =
        await UserProfileProvider.readUserProfile(userProfileProvider.userId);
    userProfileProvider.load(userProfile);
  }
}
