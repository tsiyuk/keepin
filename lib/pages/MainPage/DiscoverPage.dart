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

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return userProfileProvider.tags.length == 0
        ? TextH2('Please go to add your favourite tags')
        : StreamBuilder<List<Circle>>(
            stream: userProfileProvider.recommandCircles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading(30);
              } else {
                if (!snapshot.hasData || snapshot.data!.length == 0) {
                  return TextH1('No recommended circles');
                } else {
                  return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          clipBehavior: Clip.antiAlias,
                          child:
                              _buildCircleCard(context, snapshot.data![index]),
                        );
                      });
                }
              }
            });
  }

  Widget _buildCircleCard(BuildContext context, Circle circle) {
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
            borderRadius: BorderRadius.circular(20),
            child: Image.network(circle.avatarURL,
                width: 110, height: 110, fit: BoxFit.cover),
          ),
          TextH2(circle.circleName),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.people),
            TextH4(circle.numOfMembers.toString()),
          ]),
        ],
      ),
    );
  }
}
