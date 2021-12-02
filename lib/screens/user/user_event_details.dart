import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:awareness_admin/screens/user/user_edit_event.dart';
import 'package:awareness_admin/services/fcm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
      }).whenComplete(() async {
        await Future.delayed(const Duration(milliseconds: 500));
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

  Future<void> download(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var storagePath = await getExternalStorageDirectory();
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: storagePath!.path,
        showNotification: true,
        openFileFromNotification: true,
      );
    }
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
    loading = false;
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
        ),
        actions: [
          loading
              ? CupertinoActivityIndicator()
              : event['status'] == 'Requested'
                  ? IconButton(
                      onPressed: () {
                        Get.to(() => EditEvent(
                              eventId: widget.eventId,
                            ));
                      },
                      icon: const Icon(Icons.edit))
                  : const SizedBox(width: 0)
        ],
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
                          Flexible(
                            child: Text(
                              '${event['title']}'.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 23),
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
                            style: TextStyle(
                              color: const Color(0xFF29357c).withOpacity(0.7),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 30,
                                child: Card(
                                  shadowColor: Colors.grey[50],
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  color: Colors.grey[50],
                                  child: ListTile(
                                    minVerticalPadding: 18,
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(userImg!),
                                      radius: 27,
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    widget.userId == FirebaseAuth.instance.currentUser!.uid
                        ? Column(
                            children: [
                              event['status'] == "Approved"
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                showDialogue();
                                              },
                                              child: const Text(
                                                'Mark Completed',
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                Get.defaultDialog(
                                                    confirmTextColor:
                                                        Colors.white,
                                                    cancelTextColor:
                                                        const Color(0xFF29357c),
                                                    buttonColor:
                                                        const Color(0xFF29357c),
                                                    title: 'Report File',
                                                    middleText:
                                                        'Do you want to downlaod the Report File ?',
                                                    textCancel: 'No',
                                                    textConfirm: 'Yes',
                                                    onConfirm: () async {
                                                      Navigator.of(context)
                                                          .pop();
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
                          )
                        : Container()
                  ],
                ),
              ),
      ),
    );
  }
}
