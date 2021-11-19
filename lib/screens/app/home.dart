import 'package:awareness_admin/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Get.defaultDialog(
                    title: 'Log Out',
                    middleText: 'Do You Want To Log Out This Account',
                    textCancel: 'No',
                    textConfirm: 'Yes',
                    onConfirm: () async {
                      await FirebaseAuth.instance.signOut();
                      Get.offAll(() => const LoginScreen());
                    });
              },
              child: const Text('Logout'))
        ],
      ),
    );
  }
}
