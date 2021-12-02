import 'package:awareness_admin/constants/value_constants.dart';
import 'package:awareness_admin/screens/home.dart';

import 'package:awareness_admin/screens/otp.dart';

import 'package:awareness_admin/screens/user_details.dart';
import 'package:awareness_admin/services/fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthWrapperScreen extends StatefulWidget {
  const AuthWrapperScreen({Key? key}) : super(key: key);

  @override
  _AuthWrapperScreenState createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {
  final phoneNumberController = TextEditingController();
  FCMNotification fcmNotification = FCMNotification();
  GetStorage getStorage = GetStorage();
  late String verificationId;
  String? userType;
  int? resendToken;
  bool loading = false;

  Future<void> verifyUser(int phoneNumber) async {
    final data = await http
        .get(Uri.parse('https://womena.herokuapp.com/users/$phoneNumber'));
    print(data.body);

    if (data.statusCode == 404) {
      setState(() {
        loading = false;
      });
      Get.snackbar('UnAuthorized User',
          'You are not an authorized user of the app , Contact us for enquires');
    }
    var jsonResponse = jsonDecode(data.body) as Map<String, dynamic>;
    userType = jsonResponse['type'];
    if (data.statusCode == 200) {
      sendOtp();
    }
  }

  Future<void> sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${phoneNumberController.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (userType == 'admin') {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set({
              'notificationToken': await fcmNotification.updateDeviceToken(),
              'phone_number': FirebaseAuth.instance.currentUser!.phoneNumber,
              'type': 'admin'
            }, SetOptions(merge: true));

            Get.offAll(() => Home(
                  userType: userType!,
                ));
          } else if (userType == 'user') {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set({
              'notificationToken': await fcmNotification.updateDeviceToken(),
              'phone_number': FirebaseAuth.instance.currentUser!.phoneNumber,
              'type': 'user'
            }, SetOptions(merge: true));
            final user = await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get();

            user.data()!.isEmpty
                ? Get.off(() => UserDetails(
                      userType: userType!,
                    ))
                : Get.offAll(() => Home(
                      userType: userType!,
                    ));
          }

          Get.snackbar('OTP Verified Succesfully',
              'Your OTP Has Been Verified Automatically !');
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar('Error', "Exception" + e.message!.toString());
          if (e.code == 'invalid-phone-number') {
            Get.snackbar(
                'Invalid Number', 'The provided phone number is not valid.');
          }
          setState(() {
            loading = false;
          });

          // Handle other errors
        },
        codeSent: (String vId, int? rToken) async {
          setState(() {
            loading = false;
          });
          verificationId = vId;
          resendToken = rToken;

          Get.snackbar('OTP Sent', 'OTP has been sent to you mobile number.');
          Get.to(() => OTPScreen(
                number: phoneNumberController.text,
                verificationId: verificationId,
                resendToken: resendToken,
                userType: userType!,
              ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        forceResendingToken: resendToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
              'assets/bg.png',
            ),
            fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Column(
          children: [
            loading == true
                ? const SizedBox(
                    height: 5,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      color: Color(0xFF29357c),
                    ),
                  )
                : const SizedBox(
                    height: 5,
                  ),
            const SizedBox(
              height: 30,
            ),
            Column(
              children: const [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/christ.png'),
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 15),
                Text(
                  'Join Us To Start Saving',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  "Lets Create Awareness Together",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey),
                )
              ],
            ),
            const SizedBox(
              height: 130,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.number,
                      decoration: kTextFieldDecoration.copyWith(
                          prefixText: '+ 91  ',
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          suffixIcon: const Icon(
                            Icons.phone,
                            color: Color(0xFF29357c),
                          ))),
                  const SizedBox(
                    height: 35,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () {
                                setState(() {
                                  loading = true;
                                });
                                verifyUser(
                                    int.parse(phoneNumberController.text));
                              },
                        icon: loading == true
                            ? const Text('Loading')
                            : const Icon(Icons.person),
                        label: loading == true
                            ? const CupertinoActivityIndicator()
                            : const Text('Login'),
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
