import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CreatePostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:provider/provider.dart';

class CirclePage extends StatefulWidget {
  @override
  _CirclePageState createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> with TickerProviderStateMixin {
  User user = FirebaseAuth.instance.currentUser!;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    Widget _profileSection = Container(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset('assets/images/nus.png',
                width: 70, height: 70, fit: BoxFit.cover),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              'NUS Night Runners',
              style: TextStyle(fontSize: 17.0),
            ),
          ),
        ],
      ),
    );

    BottomNavigationBar bottomBar =
        BottomNavigationBar(items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
      BottomNavigationBarItem(icon: Icon(Icons.lock_clock), label: 'Clock in'),
      // TODO
      // the clock in may use a floating action button with CircularNotchedRectangle() for better visual effect
      BottomNavigationBarItem(
          icon: Icon(Icons.fireplace_outlined), label: 'Recommend'),
    ]);

    final _postBarItems = <Widget>[
      Tab(
        text: 'Descrption',
      ),
      Tab(text: 'Post'),
      Tab(text: 'Theme'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 160,
          child: _profileSection,
        ),
        toolbarHeight: 160,
        bottom: TabBar(
          controller: _tabController,
          tabs: _postBarItems,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Text('1'),
          StreamBuilder<List<Post>>(
              stream: postProvider.readPostsFromCircle('NUS Night Runners'),
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
                        user: user, circleName: 'NUS Night Runners')));
              }),
        ],
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}
