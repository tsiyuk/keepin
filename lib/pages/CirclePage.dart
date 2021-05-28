import 'package:flutter/material.dart';

class CirclePages extends StatefulWidget {
  @override
  _CirclePagesState createState() => _CirclePagesState();
}

class _CirclePagesState extends State<CirclePages>
    with TickerProviderStateMixin {
  TabController? _tabController = null;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Widget _profileSection = Container(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset('assets/images/nus.png',
                width: 150, height: 150, fit: BoxFit.cover),
          ),
          Container(
            padding: const EdgeInsets.all(32),
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
          height: 200,
          child: _profileSection,
        ),
        toolbarHeight: 200,
        bottom: TabBar(
          controller: _tabController,
          tabs: _postBarItems,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _postBarItems,
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}
