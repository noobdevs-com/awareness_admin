import 'dart:async';

import 'package:awareness_admin/screens/app/home.dart';
import 'package:awareness_admin/screens/app/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:awareness_admin/services/fcm.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OTPScreen extends StatefulWidget {
  final String number;
  final String verificationId;
  final int? resendToken;

  OTPScreen(
      {required this.number,
      required this.verificationId,
      required this.resendToken});

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
        final user =
            await FirebaseAuth.instance.signInWithCredential(credential);
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

      UserCredential user =
          await FirebaseAuth.instance.signInWithCredential(credential);

      Get.offAll(() => const Home());

      //  Check if user exist

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
        leadingWidth: 10,
        elevation: 0,
        title: IconButton(
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
            SizedBox(
              height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('OTP Has Been Sent To',
                          style: TextStyle(fontSize: 25)),
                      const SizedBox(
                        height: 20,
                      ),
                      Text('+91  ${widget.number}',
                          style: const TextStyle(fontSize: 20))
                    ],
                  ),
                  const Text(
                      'Please Enter The 6 - Digit Code Sent To Your Number',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 75,
                    height: 40,
                    child: PinInputTextField(
                      cursor: Cursor(color: Colors.black),
                      decoration: const BoxLooseDecoration(
                          bgColorBuilder: FixedColorBuilder(Colors.white24),
                          strokeColorBuilder:
                              FixedColorBuilder(Color(0xFFCFB840))),
                      pinLength: 6,
                      controller: otpController,
                      textInputAction: TextInputAction.go,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          verifyOtp();
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))))),
                  ),
                  RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                        text: ' Resend OTP ',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    TextSpan(
                        text: ' 00:$startTime ',
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16)),
                    const TextSpan(
                        text: ' seconds ',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ])),
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
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Resend OTP',
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Container(
                          height: 5,
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
