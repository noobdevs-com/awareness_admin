import 'package:awareness_admin/screens/login.dart';
import 'package:awareness_admin/screens/user/user_add_event.dart';
import 'package:awareness_admin/screens/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Account',
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
                  Get.to(() => const AddEvent());
                },
                title: const Text('Create Event'),
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
                  Get.to(() => const UserDetails());
                },
                title: const Text('Edit Profile'),
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
                        Get.offAll(() => const AuthWrapperScreen());
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
