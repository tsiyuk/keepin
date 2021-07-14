import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:keepin/pages/Circle/CreateCirclePage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

import '../Circle/CirclePage.dart';
import '../UserProfileDisplay.dart';

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
            child: Icon(Icons.add_box, size: 50, color: Colors.teal),
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
                              Circle circle = await circleProvider
                                  .readCircleFromName(data.circleName);
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
          // MaterialButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => CirclePage()),
          //     );
          //   },
          //   color: Colors.white,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(8),
          //     child: Image.asset('assets/images/nus.png',
          //         width: 50, height: 50, fit: BoxFit.cover),
          //   ),
          //   padding: EdgeInsets.all(6),
          //   shape: ContinuousRectangleBorder(
          //       borderRadius: BorderRadius.circular(16)),
          //   minWidth: 50,
          // ),
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
            children: [_buildFollowFeed(context), _buildRecommendation()],
          ),
        )
      ],
    );
  }

  Widget _buildFollowFeed(BuildContext context) {
    // return Center(child: Text("follow feed"));
    PostProvider postProvider =
        Provider.of<PostProvider>(context, listen: false);
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return FutureBuilder<List<Post>>(
        initialData: [],
        future: postProvider
            .readFollowPosts(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.data == []) {
            return Loading(40);
          }
          if (snapshot.data != null) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Post post = snapshot.data![index];
                userProfileProvider.updatePosterInfo(post);
                return ListTile(
                  // to be refactored
                  leading: Container(
                    height: 150,
                    width: 50,
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          child: ImageButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfileDisplay(post.posterId)));
                            },
                            image: Image.network(
                              post.posterAvatarLink!,
                              fit: BoxFit.cover,
                            ),
                            size: 40,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextH5(post.posterName)
                      ],
                    ),
                  ),
                  title: Text(post.title),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 100,
                            child: Text(
                              post.text,
                              maxLines: 8,
                            )),
                        getTimeDisplay(post.timestamp.toString()),
                      ]),
                  minLeadingWidth: 20,
                );
              },
              separatorBuilder: (c, i) => Container(
                height: 10,
                color: Colors.blueGrey.shade100,
              ),
            );
          } else {
            return Center(child: Text('No posts'));
          }
        });
  }

  Widget _buildRecommendation() {
    return Center(child: Text("Coming soon"));
  }
}
