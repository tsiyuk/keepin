import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:keepin/pages/DiscoverPage.dart';
import 'package:keepin/pages/MainPage/HomePage.dart';
import 'package:keepin/pages/MainPage/MessagePage.dart';
import 'package:keepin/pages/SearchDelegate.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'UserProfilePage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String? token;

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    initLocalNotification();
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification android = notification.android!;
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: android.smallIcon,
            ),
          ));
    });
    getToken();
  }

  void initLocalNotification() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    if (token != null) {
      // this is to avoid the error ! used on null value
      userProfileProvider.updateToken(token!);
    }

    List<Widget> _subPages = <Widget>[
      HomePage(),
      DiscoverPage(),
      MessagePage(),
      // assume that the user has logged in
      UserProfilePage(UserState.user!),
      // PrimaryButton(onPressed: userState.signOut, child: Text("Sign out")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bar'),
        actions: [
          IconButton(
              onPressed: () async {
                await showSearch(context: context, delegate: SearchData());
              },
              icon: Icon(Icons.search)),
        ],
      ),
      body: Center(
        child: _subPages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility_outlined),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
    print(message.data);
    flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.data['title'],
        message.data['body'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
          ),
        ));
  }

  void getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    print('token');
    print(token);
  }
}
