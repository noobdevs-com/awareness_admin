import 'package:awareness_admin/models/event.dart';
import 'package:awareness_admin/screens/app/event_details.dart';
import 'package:awareness_admin/screens/app/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

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
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      value: filterKey,
                      items: <String>[
                        'All',
                        'Requested',
                        'Rejected',
                        'Approved',
                        'Completed'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          filterKey = value ?? 'All';
                        });
                        if (filterKey == 'All') {
                          getEvents();
                        } else {
                          filterEvents(filterKey);
                        }
                      },
                    ),
                  ),

                  // Loader
                  loading == true
                      ? const LinearProgressIndicator(
                          backgroundColor: Colors.white,
                        )
                      : const SizedBox(height: 5),

                  // Event List
                  Expanded(
                    child: events.isEmpty
                        ? const Center(child: Text('No events found.'))
                        : ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Card(
                                    elevation: 1,
                                    shadowColor: Colors.grey[300],
                                    child: ListTile(
                                      onTap: () => Get.to(() => EventDetails(
                                            eventId: events[index].did!,
                                          )),
                                      trailing: SizedBox(
                                        width: 60,
                                        child: Center(
                                          child: Row(
                                            children: const [
                                              Text(
                                                'View',
                                                style: TextStyle(
                                                    color: Colors.grey),
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
                                        events[index].title!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Text(events[index].status!),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat.jm().format(
                                                  (events[index].startTime!),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.blue
                                                        .withOpacity(0.7),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 17),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                DateFormat.yMMMMd().format(
                                                    (events[index].startTime!)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )),
                              );
                            }),
                  ),
                ],
              ),
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
