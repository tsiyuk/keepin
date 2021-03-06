import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CirclePage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with TickerProviderStateMixin {
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
          tabs: <Widget>[
            Text("Recommendation"),
            Text("All"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildRecommendation(context), _buildAll(context)],
          ),
        )
      ],
    );
  }

  Widget _buildCircleCard(BuildContext context, Circle circle) {
    final double imageSize = MediaQuery.of(context).size.width / 4;
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        circleProvider.addCircleHistory(circle);
        Navigator.of(context).push((MaterialPageRoute(
            builder: (context) => CirclePage(
                  circle: circle,
                ))));
      },
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(circle.avatarURL,
                width: imageSize, height: imageSize, fit: BoxFit.cover),
          ),
          TextH3(
            circle.circleName,
            size: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.people,
              color: Colors.blueGrey,
            ),
            TextH4(circle.numOfMembers.toString()),
          ]),
        ],
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context) {
    return StreamBuilder<UserProfile>(
        stream: UserProfileProvider.readUserProfile(
            FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading(30);
          } else {
            if (snapshot.data == null) {
              return TextH2('Error');
            } else {
              UserProfile userProfile = snapshot.data!;
              return userProfile.tags.length == 0
                  ? Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextH3(
                            'Please go to add your favourite tags on the top right corner.'),
                      ),
                    )
                  : StreamBuilder<List<Circle>>(
                      stream: UserProfileProvider.getRecommandCircles(
                          userProfile.tags),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loading(30);
                        } else {
                          if (!snapshot.hasData || snapshot.data!.length == 0) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextH3('No recommended circles'),
                            );
                          } else {
                            return GridView.builder(
                                physics: BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.all(10),
                                    color: Colors.white,
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    clipBehavior: Clip.antiAlias,
                                    child: _buildCircleCard(
                                        context, snapshot.data![index]),
                                  );
                                });
                          }
                        }
                      });
            }
          }
        });
  }

  Widget _buildAll(BuildContext context) {
    return StreamBuilder<List<Circle>>(
        stream: CircleProvider.publicCircles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading(30);
          } else {
            if (!snapshot.hasData || snapshot.data!.length == 0) {
              return TextH1('No circles');
            } else {
              return GridView.builder(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: Colors.white,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      clipBehavior: Clip.antiAlias,
                      child: _buildCircleCard(context, snapshot.data![index]),
                    );
                  });
            }
          }
        });
  }
}
