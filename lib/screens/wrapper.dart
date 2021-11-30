import 'package:awareness_admin/screens/admin/home.dart';

import 'package:awareness_admin/screens/login.dart';
import 'package:awareness_admin/screens/user/user_home.dart';
import 'package:awareness_admin/screens/user_details.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<void> checkStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (FirebaseAuth.instance.currentUser != null) {
      final ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        var data = value.data()!;
        final usertype = data['type'];
        if (usertype == 'admin') {
          Get.off(() => const Home());
        } else if (ref.data()!.isEmpty) {
          Get.off(() => const UserDetails());
        } else {
          Get.off(() => const UserHome());
        }
      });
    } else {
      Get.off(() => const AuthWrapperScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkStatus(),
        builder: (_, s) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/christ.png'),
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  CupertinoActivityIndicator(
                    animating: true,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
