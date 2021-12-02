import 'dart:io';

import 'package:awareness_admin/constants/value_constants.dart';
import 'package:awareness_admin/screens/home.dart';

import 'package:awareness_admin/services/fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class UserSOSScreen extends StatefulWidget {
  const UserSOSScreen({Key? key}) : super(key: key);

  @override
  _UserSOSScreenState createState() => _UserSOSScreenState();
}

class _UserSOSScreenState extends State<UserSOSScreen> {
  final discriptionController = TextEditingController();
  final files = <XFile>[];
  final _picker = ImagePicker();
  bool loading = false;
  DateTime? selectedDateTime;
  final imagePaths = <String>[];
  late Position _currentPosition;
  List<String> adminToken = [];
  FCMNotification fcmNotification = FCMNotification();
  String? userName;

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

  Future<Position?> getlocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _currentPosition = position;

      return position;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getFirebaseUserData() async {
    setState(() {
      loading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      var data = value.docs[0].data();
      setState(() {
        userName = data['name'];
      });
    }).whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getlocation();
    getAdminToken();
    getFirebaseUserData();
  }

  @override
  void dispose() {
    super.dispose();
    loading = false;
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

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
        ),
        backgroundColor: const Color(0xfff8f8f8),
        body: loading
            ? const SizedBox(
                height: 250,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Loader
                    loading == true
                        ? const LinearProgressIndicator(
                            color: Color(0xFF29357c),
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
                            'Send SOS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Created by ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                userName ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 16,
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
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: discriptionController,
                            textAlign: TextAlign.left,
                            maxLines: 5,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Comments'),
                          ),
                          const SizedBox(height: 22),
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
                                    if (loading == true) return;

                                    setState(() {
                                      loading = true;
                                    });
                                    for (var i = 0; i < files.length; i++) {
                                      TaskSnapshot image = await FirebaseStorage
                                          .instance
                                          .ref(
                                              'sosImages/${UniqueKey().toString() + files[i].name}')
                                          .putFile(File(files[i].path));
                                      imagePaths.add(
                                          await image.ref.getDownloadURL());
                                    }
                                    await FirebaseFirestore.instance
                                        .collection('sos')
                                        .add({
                                      'coordinates': [
                                        _currentPosition.latitude,
                                        _currentPosition.longitude
                                      ],
                                      'uid': FirebaseAuth
                                          .instance.currentUser!.uid,
                                      'description': discriptionController.text,
                                      'images': imagePaths,
                                      'createdAt': DateTime.now(),
                                      'name': userName!
                                    }).whenComplete(() async {
                                      setState(() {
                                        adminToken.forEach((e) =>
                                            fcmNotification.createNotification(
                                                e,
                                                'SOS Request',
                                                'New SOS Request Incoming !'));

                                        loading = false;
                                        discriptionController.clear();
                                        imagePaths.clear();
                                        files.clear();
                                        Get.snackbar('SOS Sent',
                                            'SOS request has been sent.');
                                      });
                                      await Future.delayed(
                                          const Duration(milliseconds: 1500));
                                      Get.back();
                                    });
                                  },
                                  child: const Text(
                                    'Send SOS',
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
