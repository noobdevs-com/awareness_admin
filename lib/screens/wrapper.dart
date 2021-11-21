import 'package:awareness_admin/screens/auth/login.dart';
import 'package:awareness_admin/screens/auth/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  Future<void> checkStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (FirebaseAuth.instance.currentUser != null) {
      Get.to(() => const Home());
    } else {
      Get.to(() => const LoginScreen());
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
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
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
