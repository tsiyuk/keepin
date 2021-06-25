import 'package:flutter/material.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/services/SearchService.dart';

// class SearchResultPage extends StatefulWidget {
//   const SearchResultPage({Key? key}) : super(key: key);

//   @override
//   _SearchResultPageState createState() => _SearchResultPageState();
// }

// class _SearchResultPageState extends State<SearchResultPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

class CircleSearch extends SearchDelegate<dynamic> {
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
              return buildResultSuccess(snapshot.data!);
            }
        }
      },
    );
  }

  Widget buildResultSuccess(List<Circle> datas) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return CircleBuilder.buildCircle(datas[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

class CircleBuilder {
  static Widget buildCircle(Circle circle) {
    return Container(
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
    );
  }
}
