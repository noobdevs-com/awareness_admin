import 'dart:io';

import 'package:awareness_admin/constants/value_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final files = <XFile>[];
  final _picker = ImagePicker();
  bool loading = false;
  DateTime? selectedDateTime;
  final imagePaths = <String>[];

  void _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image == null) return;

    setState(() {
      files.add(image);
    });
  }

  void _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: const Color(0xfff8f8f8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Loader
            loading == true
                ? const LinearProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : const SizedBox(height: 5),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Create Event',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextField(
                    textAlign: TextAlign.left,
                    onChanged: (value) {},
                    decoration:
                        kTextFieldDecoration.copyWith(hintText: 'Event Title'),
                  ),
                  const SizedBox(
                    height: 17,
                  ),
                  TextField(
                    textAlign: TextAlign.left,
                    maxLines: 5,
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Event description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () => setTime(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set Time 🕐',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        selectedDateTime == null
                            ? const Text(
                                "Tap to set time",
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              )
                            : Text(
                                selectedDateTime!.toLocal().toString(),
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
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
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: const BorderRadius.all(
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
                            color: Colors.blueAccent, width: 2),
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
                                  leading: const Icon(Icons.photo_album),
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
                        style: TextStyle(color: Colors.blueAccent),
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
                                color: Colors.blueAccent, width: 2),
                          ),
                          onPressed: () async {
                            if (loading == true) return;
                            imagePaths.clear();
                            files.clear();

                            setState(() {
                              loading = true;
                            });
                            for (var i = 0; i < files.length; i++) {
                              TaskSnapshot image = await FirebaseStorage
                                  .instance
                                  .ref(
                                      'eventImages/${UniqueKey().toString() + files[i].name}')
                                  .putFile(File(files[i].path));
                              imagePaths.add(await image.ref.getDownloadURL());
                            }
                            await FirebaseFirestore.instance
                                .collection('events')
                                .add({
                              'status': "Requested",
                              'user_id': FirebaseAuth.instance.currentUser!.uid,
                              'start_time': selectedDateTime!.toIso8601String(),
                              'title': 'title',
                              'description': 'description',
                              'images': imagePaths,
                              'createdAt': DateTime.now(),
                            }).whenComplete(() => setState(() {
                                      setState(() {
                                        loading = false;
                                      });
                                    }));
                          },
                          child: const Text(
                            'Create Event',
                            style: TextStyle(color: Colors.blueAccent),
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
    );
  }
}
