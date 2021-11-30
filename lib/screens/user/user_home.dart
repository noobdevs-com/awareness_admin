import 'package:awareness_admin/screens/user/user_events.dart';
import 'package:awareness_admin/screens/user/user_profile.dart';
import 'package:awareness_admin/screens/user/user_sos.dart';
import 'package:awareness_admin/services/local_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;
  late PageController _pageController;

  void onPageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }

  void onTabTapped(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

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

  @override
  Widget build(BuildContext context) {
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
              children: const [UserEventScreen(), UserProfile()]),
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
          floatingActionButton: FloatingActionButton(
            elevation: 1,
            onPressed: () {
              Get.to(() => const UserSOSScreen());
            },
            child: const Icon(
              Icons.warning,
            ),
          )),
    );
  }
}
