import 'package:awareness_admin/screens/app/add_college.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   title: const Text(
      //     'Profile',
      //     style: TextStyle(color: Colors.black),
      //   ),
      // ),
      body: Padding(
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
    );
  }
}
