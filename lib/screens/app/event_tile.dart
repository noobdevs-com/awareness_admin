import 'package:awareness_admin/models/event.dart';
import 'package:awareness_admin/screens/app/event_details.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EventTile extends StatefulWidget {
  const EventTile({Key? key}) : super(key: key);

  @override
  _EventTileState createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  String filterKey = 'All';
  List<Event> events = [];

  bool loading = false;

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
            images: ref.docs[i]['images'],
            uid: ref.docs[i]['uid'],
            did: ref.docs[i].id,
            title: ref.docs[i]["title"],
            status: ref.docs[i]["status"],
            startTime: DateTime.parse(ref.docs[i]["start_time"]),
          );
          events.add(event);
        }
        loading = false;
      });
    } catch (e) {
      Get.snackbar("oops...", "Unable to get events");
      setState(() {
        loading = false;
      });
    }
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
          images: ref.docs[i]['images'],
          uid: ref.docs[i]['uid'],
          did: ref.docs[i].id,
          title: ref.docs[i]["title"],
          status: ref.docs[i]["status"],
          startTime: DateTime.parse(
            ref.docs[i]["start_time"],
          ),
        );
        events.add(event);
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      Get.snackbar("Oops...", "Unable to get events");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        toolbarHeight: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2, top: 5),
              child: Text(
                'Hello, ${FirebaseAuth.instance.currentUser!.phoneNumber}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                DateFormat.yMMMMEEEEd().format(DateTime.now()),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: getEvents,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                        child: Text(
                          value,
                        ),
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
              ],
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
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              elevation: 1,
                              shadowColor: Colors.grey[300],
                              child: Column(
                                children: [
                                  SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8)),
                                        child: Image(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              events[index].images.first),
                                        ),
                                      )),
                                  ListTile(
                                    onTap: () => Get.to(() => EventDetails(
                                        eventId: events[index].did!,
                                        userId: events[index].uid!)),
                                    trailing: SizedBox(
                                      width: 60,
                                      child: Center(
                                        child: Row(
                                          children: const [
                                            Text(
                                              'View',
                                              style:
                                                  TextStyle(color: Colors.grey),
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
                                      events[index].title!.toUpperCase(),
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
                                                color: const Color(0xFF29357c)
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              DateFormat.yMMMMd().format(
                                                  (events[index].startTime!)),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}
