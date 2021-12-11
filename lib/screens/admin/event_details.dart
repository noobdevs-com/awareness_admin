import 'dart:isolate';
import 'dart:ui';
import 'package:awareness_admin/services/fcm.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String? notifyId;
  bool loading = false;

  Future<void> download(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var storagePath = await getExternalStorageDirectory();
      await FlutterDownloader.enqueue(
          url: url,
          savedDir: storagePath!.path,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true);
    }
  }

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
          notifyId = data['notificationToken'];
        });
      }).whenComplete(() async {
        await Future.delayed(const Duration(milliseconds: 300));
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

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    getEvent();
    getUser(widget.userId);

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Event Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
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
                        indicatorColor: const Color(0xFF29357c),
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
                            event['venue'],
                            style: TextStyle(
                              color: const Color(0xFF29357c).withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.location_pin)
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
                              color: Color(0xFF29357c),
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
                          radius: 27,
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
                                    await updateStatus("Rejected")
                                        .whenComplete(() {
                                      Get.snackbar('Event Rejected',
                                          'You have Rejected the event');
                                      FCMNotification().createNotification(
                                          notifyId!,
                                          ' Resquest Rejected',
                                          'Your event eequest has been rejected by Admin');
                                    });
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
                                    await updateStatus("Approved")
                                        .whenComplete(() {
                                      Get.snackbar('Event Approved',
                                          'You have Approved the event');
                                      FCMNotification().createNotification(
                                          notifyId!,
                                          ' Request Approved',
                                          'Your event eequest has been approved by Admin');
                                    });
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Get.defaultDialog(
                                          confirmTextColor: Colors.white,
                                          cancelTextColor:
                                              const Color(0xFF29357c),
                                          buttonColor: const Color(0xFF29357c),
                                          title: 'Report File',
                                          middleText:
                                              'Do you want to downlaod the Report File ?',
                                          textCancel: 'No',
                                          textConfirm: 'Yes',
                                          onConfirm: () async {
                                            Navigator.of(context).pop();
                                            await download(
                                                event['report_file']);
                                          });
                                    },
                                    child: const Text(
                                      'View Report',
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
