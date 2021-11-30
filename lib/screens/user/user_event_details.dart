import 'dart:io';

import 'package:awareness_admin/services/fcm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class UserEventDetails extends StatefulWidget {
  final String eventId;
  final String userId;
  const UserEventDetails(
      {Key? key, required this.eventId, required this.userId})
      : super(key: key);

  @override
  _UserEventDetailsState createState() => _UserEventDetailsState();
}

class _UserEventDetailsState extends State<UserEventDetails> {
  dynamic event;
  String? userName;
  String? userImg;
  bool loading = false;
  bool linearLoading = false;
  PlatformFile? file;
  List<String> adminToken = [];

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

  Future<void> getAdminToken() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('type', isEqualTo: 'admin')
        .get()
        .then((value) {
      final data = value.docs.map<String>((e) => e['notificationToken']);
      adminToken = data.toList();
    });
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
      setState(() {
        loading = false;
      });
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> updateStatus() async {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({"status": "Completed"}).whenComplete(() {
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

  showDialogue() {
    Get.defaultDialog(
      title: "Mark Complete",
      content: Column(
        children: [
          const Text("Please upload your report in pdf format."),
          ElevatedButton(
            onPressed: pickFile,
            child: const Text(
              "Select File.",
            ),
          )
        ],
      ),
    );
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    Get.back();
    if (result == null) return;
    file = result.files.single;
    Get.defaultDialog(
      title: "Confirm?",
      content: Column(
        children: [
          const Text("Marking complete with the selected file."),
          const SizedBox(height: 4),
          Text(file!.name),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () => uploadFileAndUpdateEvent(file!),
            child: const Text(
              "Mark Complete",
            ),
          )
        ],
      ),
    );
    setState(() {
      file = result.files.single;
    });
  }

  Future<void> uploadFileAndUpdateEvent(PlatformFile pickedFile) async {
    Get.back();
    setState(() {
      linearLoading = true;
    });
    TaskSnapshot image = await FirebaseStorage.instance
        .ref('eventImages/${UniqueKey().toString() + pickedFile.name}')
        .putFile(File(pickedFile.path!));
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .update({
      "report_file": await image.ref.getDownloadURL(),
      "status": "Completed",
    }).whenComplete(() {
      for (var e in adminToken) {
        FCMNotification().createNotification(
            e, 'Event Completed', 'Event has been marked as completed by user');
      }
    });
    setState(() {
      linearLoading = false;
    });
    getEvent();
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
        ),
        leadingWidth: 24,
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
                          Flexible(
                            child: Text(
                              '${event['title']}'.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
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
                    loading
                        ? Container(
                            height: 5,
                          )
                        : Card(
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
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
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
                    widget.userId == FirebaseAuth.instance.currentUser!.uid
                        ? Column(
                            children: [
                              event['status'] == "Approved"
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                showDialogue();
                                              },
                                              child: const Text(
                                                'Mark Completed',
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .resolveWith((states) =>
                                                            Colors.blue),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
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
                                                  await launch(
                                                      event['report_file']);
                                                } else {
                                                  await launch(
                                                      event['report_file']);
                                                }
                                              },
                                              child: const Text(
                                                'View Report',
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .resolveWith((states) =>
                                                            Colors.blue),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          )
                        : Container()
                  ],
                ),
              ),
      ),
    );
  }
}
