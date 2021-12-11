import 'dart:async';
import 'package:awareness_admin/screens/home.dart';
import 'package:awareness_admin/screens/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:awareness_admin/services/fcm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OTPScreen extends StatefulWidget {
  final String number;
  final String verificationId;
  final int? resendToken;
  final String userType;

  OTPScreen(
      {required this.number,
      required this.verificationId,
      required this.resendToken,
      required this.userType});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final otpController = TextEditingController();
  FCMNotification fcmNotification = FCMNotification();
  GetStorage getStorage = GetStorage();

  bool loading = false;
  int? resendToken;
  late String _verificationId;
  int startTime = 59;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    resendToken = widget.resendToken;
    startTimer();
  }

  Future<void> reSendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.number}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (widget.userType == 'admin') {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set({
            'notificationToken': await fcmNotification.updateDeviceToken(),
            'phone_number': FirebaseAuth.instance.currentUser!.phoneNumber,
            'type': 'admin'
          }, SetOptions(merge: true)).whenComplete(() {});
        } else if (widget.userType == 'user') {
          final user = await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

          user.data()!.isEmpty
              ? Get.off(() => UserDetails(
                    userType: widget.userType,
                  ))
              : Get.offAll(() => Home(userType: widget.userType));
        }

        Get.snackbar('OTP Verified Succesfully',
            'Your OTP Has Been Verified Automatically !');
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          Get.snackbar(
              'Invalid Number', 'Please Check the number you have entered');
        }
      },
      codeSent: (String vId, int? rtoken) async {
        resendToken = rtoken;

        Get.snackbar('OTP Sent', 'OTP has been sent to you mobile number');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: resendToken,
    );
  }

  Future<void> verifyOtp() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: otpController.text);

      // Sign the user in (or link) with the credential

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (widget.userType == 'admin') {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'notificationToken': await fcmNotification.updateDeviceToken(),
          'phone_number': FirebaseAuth.instance.currentUser!.phoneNumber,
          'type': 'admin'
        }, SetOptions(merge: true));

        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return Home(
            userType: widget.userType,
          );
        }));
      } else if (widget.userType == 'user') {
        final user = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        !user.exists
            ? Get.off(() => UserDetails(
                  userType: widget.userType,
                ))
            : Navigator.push(context, MaterialPageRoute(builder: (_) {
                return Home(
                  userType: widget.userType,
                );
              }));
      }

      setState(() {
        loading = false;
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      Get.snackbar('Try Again', 'The Entered Code is invalid');
    }
  }

  late Timer _timer;

  void startTimer() {
    const onesec = Duration(seconds: 1);
    _timer = Timer.periodic(onesec, (timer) {
      if (startTime == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          startTime--;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            loading == true
                ? const SizedBox(
                    height: 5,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      color: Color(0xFFCFB840),
                    ),
                  )
                : Container(
                    height: 5,
                  ),
            Column(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const Text('OTP Has Been Sent To',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('+91  ${widget.number}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey))
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 75,
                  height: 40,
                  child: PinInputTextField(
                    cursor: Cursor(color: Colors.black),
                    decoration: const BoxLooseDecoration(
                        bgColorBuilder: FixedColorBuilder(Colors.white24),
                        strokeColorBuilder:
                            FixedColorBuilder(Color(0xFF29357c))),
                    pinLength: 6,
                    controller: otpController,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 75,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        verifyOtp();
                      },
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Verify OTP'),
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))))),
                ),
                const SizedBox(
                  height: 30,
                ),
                RichText(
                    text: TextSpan(children: [
                  const TextSpan(
                      text: ' Resend OTP ',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                  TextSpan(
                      text: ' 00:$startTime ',
                      style: TextStyle(
                          color: const Color(0xFF29357c).withOpacity(0.7),
                          fontSize: 16)),
                  const TextSpan(
                      text: ' seconds ',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ])),
                const SizedBox(
                  height: 30,
                ),
                startTime == 0
                    ? TextButton.icon(
                        onPressed: () {
                          reSendOtp();
                          if (mounted) {
                            setState(() {
                              startTime = 59;
                            });
                          }
                          startTimer();
                        },
                        icon: const Icon(
                          Icons.restore,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          'Resend OTP',
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    : Container(
                        height: 5,
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
