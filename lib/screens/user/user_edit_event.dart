import 'dart:io';

import 'package:awareness_admin/constants/value_constants.dart';
import 'package:awareness_admin/screens/home.dart';

import 'package:awareness_admin/services/fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditEvent extends StatefulWidget {
  String eventId;
  EditEvent({Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  dynamic event;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final venueController = TextEditingController();
  final files = <XFile>[];
  final _picker = ImagePicker();
  bool loading = false;
  DateTime? selectedDateTime;
  final imagePaths = <String>[];
  List<String> adminToken = [];
  FCMNotification fcmNotification = FCMNotification();

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
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        titleController.text = event['title'];
        descriptionController.text = event['description'];
        venueController.text = event['venue'];
        loading = false;
      });
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
      setState(() {
        loading = false;
      });
    }
  }

  void _imgFromCamera() async {
    XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxHeight: 1080,
        maxWidth: 10080);
    if (image == null) return;

    setState(() {
      files.add(image);
    });
  }

  void _imgFromGallery() async {
    XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 1080,
        maxWidth: 1080);
    if (image == null) return;

    setState(() {
      files.add(image);
    });
  }

  void setTime() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (pickedDate == null) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;
    setState(() {
      selectedDateTime = pickedDate
          .add(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));
    });
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

  @override
  void initState() {
    super.initState();
    getAdminToken();
    getEvent();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(),
        backgroundColor: const Color(0xfff8f8f8),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Loader
              loading
                  ? const LinearProgressIndicator(
                      color: Color(0xFF29357c),
                      backgroundColor: Colors.white,
                    )
                  : const SizedBox(height: 5),

              // Content
              loading
                  ? const SizedBox(
                      height: 250,
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Edit Event',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Cannot be Empty';
                              }
                              return null;
                            },
                            controller: titleController,
                            textAlign: TextAlign.left,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Event Title'),
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Cannot be Empty';
                              }
                              return null;
                            },
                            controller: descriptionController,
                            textAlign: TextAlign.left,
                            maxLines: 5,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Event description'),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Cannot be Empty';
                                }
                                return null;
                              },
                              controller: venueController,
                              textAlign: TextAlign.left,
                              decoration: kTextFieldDecoration.copyWith(
                                  hintText: 'Event Venue')),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () => setTime(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Set Time  🕐',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                selectedDateTime == null
                                    ? Row(
                                        children: [
                                          Text(
                                            DateFormat.yMMMMEEEEd().format(
                                                event['startTime'].toDate()),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF29357c),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat.jm().format(
                                                event['startTime'].toDate()),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF29357c),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            DateFormat.yMMMMEEEEd()
                                                .format(selectedDateTime!),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF29357c)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat.jm()
                                                .format(selectedDateTime!),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF29357c)),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Images',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          files.isEmpty
                              ? Container()
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.70,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: files.length,
                                  itemBuilder: (_, i) {
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          width: 180,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(8)),
                                          ),
                                          child: Image.file(
                                            File(files[i].path),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                files.removeAt(i);
                                              });
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                ),
                          SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF29357c), width: 2),
                              ),
                              onPressed: () {
                                Get.defaultDialog(
                                    title: 'Choose Photo',
                                    content: Column(
                                      children: [
                                        ListTile(
                                          title: const Text('Camera'),
                                          leading: const Icon(Icons.camera),
                                          onTap: () {
                                            _imgFromCamera();
                                            Get.back();
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Gallery'),
                                          leading:
                                              const Icon(Icons.photo_album),
                                          onTap: () {
                                            _imgFromGallery();
                                            Get.back();
                                          },
                                        ),
                                      ],
                                    ));
                              },
                              child: const Text(
                                'Add Image',
                                style: TextStyle(color: Color(0xFF29357c)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 60,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFF29357c), width: 2),
                                  ),
                                  onPressed: () async {
                                    if (files.isEmpty) {
                                      return Get.snackbar('Oops...',
                                          'Please add atleast one image');
                                    }
                                    if (selectedDateTime == null ||
                                        selectedDateTime!
                                            .isBefore(DateTime.now())) {
                                      return Get.snackbar(
                                          'Oops...', 'Please set proper time');
                                    }
                                    if (_formKey.currentState!.validate()) {
                                      if (loading == true) return;

                                      setState(() {
                                        loading = true;
                                      });
                                      for (var i = 0; i < files.length; i++) {
                                        TaskSnapshot image = await FirebaseStorage
                                            .instance
                                            .ref(
                                                'eventImages/${UniqueKey().toString() + files[i].name}')
                                            .putFile(File(files[i].path));
                                        imagePaths.add(
                                            await image.ref.getDownloadURL());
                                      }
                                      await FirebaseFirestore.instance
                                          .collection('events')
                                          .doc(widget.eventId)
                                          .set({
                                        'status': "Requested",
                                        'uid': FirebaseAuth
                                            .instance.currentUser!.uid,
                                        'startTime': selectedDateTime!,
                                        'title': titleController.text,
                                        'description':
                                            descriptionController.text,
                                        'venue': venueController.text,
                                        'images': imagePaths,
                                        'createdAt': DateTime.now(),
                                      }).whenComplete(() async {
                                        for (var e in adminToken) {
                                          await fcmNotification
                                              .createNotification(
                                                  e,
                                                  'Event Modified',
                                                  'An Event has been modified !')
                                              .whenComplete(() {
                                            Get.snackbar('Event Modified',
                                                'Your Event has been succesfully edited!');
                                          });
                                        }

                                        setState(() {
                                          loading = false;
                                        });
                                        Get.back();
                                      });
                                    }
                                  },
                                  child: const Text(
                                    'Create Event',
                                    style: TextStyle(color: Color(0xFF29357c)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
