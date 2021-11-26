import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetails extends StatefulWidget {
  final String eventId;
  final String userId;
  const EventDetails({Key? key, required this.eventId, required this.userId})
      : super(key: key);

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  dynamic event;
  String? userName;
  String? userImg;
  bool loading = false;

  Future getUser(userid) async {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .get()
          .then((value) {
        var data = value.data()!;
        setState(() {
          userName = data['name'];
          userImg = data['profile_img'];
        });
      }).whenComplete(() {
        setState(() {
          loading = false;
        });
      });
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getEvent() async {
    setState(() {
      loading = true;
    });
    try {
      DocumentSnapshot response = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();
      event = response.data();
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> updateStatus(String status) async {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({"status": status});
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getEvent();
    getUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Details",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await getEvent();
          return;
        },
        child: loading
            ? const SizedBox(
                height: 250,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 280,
                      width: MediaQuery.of(context).size.width,
                      child: ImageSlideshow(
                        autoPlayInterval: 3000,
                        isLoop: true,
                        children: event['images']
                            .map<Widget>(
                              (img) => Container(
                                height: 280,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  image:
                                      DecorationImage(image: NetworkImage(img)),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Text(
                            event['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Text(
                            event['status'],
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: ReadMoreText(
                        event['description'],
                        trimLines: 5,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        colorClickableText: Colors.grey,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Read more',
                        trimExpandedText: 'Read less',
                        moreStyle:
                            const TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Card(
                      child: ListTile(
                        minVerticalPadding: 20,
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(userImg!),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hosted By',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              userName!,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Approve or Reject
                    event['status'] == "Requested"
                        ? Row(children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await updateStatus("Rejected");
                                    await getEvent();
                                  },
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await updateStatus("Approved");
                                    await getEvent();
                                  },
                                  child: const Text('Approve'),
                                ),
                              ),
                            ),
                          ])
                        : Container(),

                    // Completed Status
                    event['status'] == "Completed"
                        ? Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (await canLaunch(
                                          event['report_file'])) {
                                        await launch(event['report_file']);
                                      } else {
                                        throw 'Could not open the file.';
                                      }
                                    },
                                    child: const Text(
                                      'View Report',
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.blue),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
      ),
    );
  }
}
