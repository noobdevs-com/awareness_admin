import 'package:awareness_admin/models/event.dart';
import 'package:awareness_admin/screens/admin/event_tile.dart';
import 'package:awareness_admin/screens/admin/profile.dart';
import 'package:awareness_admin/screens/admin/sos.dart';
import 'package:awareness_admin/screens/user/user_events.dart';
import 'package:awareness_admin/screens/user/user_profile.dart';
import 'package:awareness_admin/services/local_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  String userType;
  Home({Key? key, required this.userType}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late PageController _pageController;
  List<Event> events = [];
  String filterKey = 'All';
  bool loading = false;

  void onPageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }

  void onTabTapped(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Future<void> getEvents() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot ref =
          await FirebaseFirestore.instance.collection('events').get();
      events.clear();
      for (var i = 0; i < ref.docs.length; i++) {
        Event event = Event(
          did: ref.docs[i].id,
          title: ref.docs[i]["title"],
          status: ref.docs[i]["status"],
          startTime: DateTime.parse(ref.docs[i]["start_time"]),
        );
        events.add(event);
      }
    } catch (e) {
      Get.snackbar("oops...", "Unable to get events");
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> filterEvents(String status) async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot ref = await FirebaseFirestore.instance
          .collection('events')
          .where('status', isEqualTo: status)
          .get();
      events.clear();

      setState(() {
        for (var i = 0; i < ref.docs.length; i++) {
          Event event = Event(
            did: ref.docs[i].id,
            title: ref.docs[i]["status"],
            status: ref.docs[i]["status"],
            startTime: DateTime.parse(ref.docs[i]["start_time"]),
          );
          events.add(event);
        }
      });
    } catch (e) {
      Get.snackbar("oops...", "Unable to get events");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    getEvents();

    LocalNotification.initialize(context);
    FirebaseMessaging.instance.getInitialMessage().then((m) {
      if (m != null) {
        final routeMessage = m.data['route'];
        Navigator.of(context).pushNamed(routeMessage);
      }
    });
    FirebaseMessaging.onMessage.listen((m) {
      LocalNotification.displayHeadsUpNotification(m);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      final routeMessage = m.data['route'];
      print(routeMessage);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Widget adminHome() {
    return WillPopScope(
      onWillPop: () async {
        Get.defaultDialog(
            title: 'Exit Application',
            middleText: 'Do you want to exit the app ?',
            textCancel: 'No',
            textConfirm: 'Yes',
            onConfirm: () {
              SystemNavigator.pop();
            });
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: PageView(
            onPageChanged: onPageChanged,
            controller: _pageController,
            children: const [
              EventTile(),
              SOSScreen(),
              Profile(),
            ]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          currentIndex: _selectedIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning),
              label: 'SOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            )
          ],
        ),
      ),
    );
  }

  Widget userHome() {
    return WillPopScope(
      onWillPop: () async {
        Get.defaultDialog(
            title: 'Exit Application',
            middleText: 'Do you want to exit the app ?',
            textCancel: 'No',
            textConfirm: 'Yes',
            onConfirm: () {
              SystemNavigator.pop();
            });
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: PageView(
            onPageChanged: onPageChanged,
            controller: _pageController,
            children: [
              UserEventScreen(),
              UserProfile(
                userType: widget.userType,
              )
            ]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          currentIndex: _selectedIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.userType == 'admin' ? adminHome() : userHome();
  }
}