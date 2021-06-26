import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CirclePage.dart';
import 'package:keepin/pages/UserProfileDisplay.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/SearchService.dart';

class SearchData extends SearchDelegate<dynamic> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
            showSuggestions(context);
          }
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Feed(query: query);
  }

  Widget buildResultSuccess(List<Circle> datas) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CircleBuilder.buildCircle(datas[index], context);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

class CircleBuilder {
  static Widget buildCircle(Circle circle, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push((MaterialPageRoute(
            builder: (context) => CirclePage(circle: circle))));
      },
      child: Container(
        width: 130,
        height: 50,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                circle.avatarURL,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 4),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  child: Text(
                    circle.circleName,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Text(
                  'Members: ${circle.numOfMembers}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Feed extends StatefulWidget {
  final String query;
  Feed({Key? key, required this.query}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          tabs: <Widget>[Text("Circles"), Text("Users"), Text('Posts')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCirclesFeed(widget.query),
              _buildUsersFeed(widget.query),
              _buildPostsFeed(widget.query),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCirclesFeed(String query) {
    return StreamBuilder<List<Circle>>(
      stream: SearchService.searchCircle(query),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Loading(20.0));
          default:
            if (snapshot.hasError) {
              return Container(
                color: Theme.of(context).accentColor,
                alignment: Alignment.center,
                child: Text(
                  'No result for $query!',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              );
            } else {
              return ListView.builder(itemBuilder: (context, index) {
                return CircleBuilder.buildCircle(
                    snapshot.data![index], context);
              });
            }
        }
      },
    );
  }

  Widget _buildUsersFeed(String query) {
    return StreamBuilder<List<UserProfile>>(
      stream: SearchService.searchUserProfile(query),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Loading(20.0));
          default:
            if (snapshot.hasError) {
              return Container(
                color: Theme.of(context).accentColor,
                alignment: Alignment.center,
                child: Text(
                  'No result for $query!',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              );
            } else {
              return ListView.builder(itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            UserProfileDisplay(snapshot.data![index].userId)));
                  },
                  child: Container(
                    width: 130,
                    height: 50,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            snapshot.data![index].avatarURL!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 4),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 200,
                              child: Text(
                                snapshot.data![index].userName,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
            }
        }
      },
    );
  }

  Widget _buildPostsFeed(String query) {
    return Container();
  }
}
