import 'package:awareness_admin/screens/app/add_college.dart';
import 'package:awareness_admin/screens/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        leadingWidth: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: ListTile(
                onTap: () {
                  Get.to(() => const AddCollege());
                },
                title: const Text('Add College'),
                trailing: const Icon(
                  Icons.arrow_right,
                  size: 26,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: ListTile(
                onTap: () {
                  Get.defaultDialog(
                      confirmTextColor: Colors.white,
                      cancelTextColor: const Color(0xFF29357c),
                      buttonColor: const Color(0xFF29357c),
                      title: 'Log Out',
                      middleText: 'Do You Want To Log Out This Account ?',
                      textCancel: 'No',
                      textConfirm: 'Yes',
                      onConfirm: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(() => const LoginScreen());
                      });
                },
                title: const Text('Logout'),
                trailing: const Icon(
                  Icons.arrow_right,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
