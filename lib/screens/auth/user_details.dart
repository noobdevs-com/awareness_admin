import 'dart:io';
import 'package:awareness_admin/screens/app/home.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({Key? key}) : super(key: key);
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  bool loading = false;

  final ref = FirebaseFirestore.instance
      .collection('admins')
      .where('adminId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final addressController = TextEditingController();

  XFile? _image;

  final _picker = ImagePicker();

  void _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    _cropImage(File(image!.path));

    setState(() {
      _image = image;
    });
  }

  _cropImage(filePath) async {
    File? croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 1080,
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                children: [
                  Stack(children: [
                    Container(
                      color: Colors.blue,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                    ),
                    Positioned(
                      top: 170,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          'Sign Up with your Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: const [
                            Text('All fields are manditory ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey,
                                    letterSpacing: 0.5)),
                            Text('*',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.red))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
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
                            child: CircleAvatar(
                              radius: 50,
                              child: _image != null
                                  ? ClipRRect(
                                      child: Image.file(
                                        File(_image!.path),
                                        fit: BoxFit.fitWidth,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter Your Name',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Ph No.',
                            hintText: 'Enter Your Phone Number',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: SizedBox(
                      height: 50,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter Your Email',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.person),
                    label: const Text('Proceed'),
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
