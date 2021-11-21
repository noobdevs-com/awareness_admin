import 'package:awareness_admin/screens/app/profile.dart';
import 'package:flutter/material.dart';
import 'package:awareness_admin/constants/constants.dart';
import 'package:awareness_admin/models/event.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  List<Event> events = [
    Event(
        eventStatus: EventStatus.pending,
        title: 'Hello Dhostu',
        eventAssignedAt: DateTime(2021, 07, 24),
        eventCreatedAt: DateTime(2021, 07, 01))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          leading: null,
          leadingWidth: 0,
          elevation: 0.5,
          shadowColor: Colors.white70,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 10),
              child: Row(
                children: const [
                  Text(
                    'YOUR EVENTS',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.grey),
                  )
                ],
              ),
            ),
          ),
          backgroundColor: Colors.white,
          toolbarHeight: 90,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 2, top: 5),
                child: Text(
                  'Hello, User',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Oct 21, 2021',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: PageView(
            onPageChanged: onPageChanged,
            controller: _pageController,
            children: [
              ListView.builder(itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Card(
                      elevation: 1,
                      shadowColor: Colors.grey[300],
                      child: ListTile(
                        trailing: SizedBox(
                          width: 60,
                          child: Center(
                            child: Row(
                              children: const [
                                Text(
                                  'View',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(
                                  Icons.arrow_right,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                        title: Text(
                          events[0].title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 2,
                            ),
                            Text(events[0].eventStatus == EventStatus.approved
                                ? 'Approved'
                                : events[0].eventStatus == EventStatus.completed
                                    ? 'Completed'
                                    : events[0].eventStatus ==
                                            EventStatus.pending
                                        ? 'Pending'
                                        : events[0].eventStatus ==
                                                EventStatus.rejected
                                            ? 'Rejected'
                                            : 'Requested'),
                            const SizedBox(
                              height: 3,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${DateFormat.jm().format((events[0].eventAssignedAt))}',
                                  style: TextStyle(
                                      color: Colors.blue.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    '${DateFormat.yMMMMd().format((events[0].eventAssignedAt))}'),
                              ],
                            )
                          ],
                        ),
                      )),
                );
              }),
              Text('Hello'),
              const Profile()
            ]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          currentIndex: _selectedIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                activeIcon: CircleAvatar(
                  child: Icon(Icons.home),
                ),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.question_answer),
                label: 'Activity',
                activeIcon: CircleAvatar(
                  child: Icon(Icons.local_activity),
                )),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
                activeIcon: CircleAvatar(child: Icon(Icons.person)))
          ],
        ));
  }
}
