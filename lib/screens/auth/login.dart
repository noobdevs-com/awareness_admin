import 'package:awareness_admin/screens/auth/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneNumberController = TextEditingController();
  GetStorage getStorage = GetStorage();
  late String verificationId;
  int? resendToken;
  bool loading = false;

  Future<void> verifyUser(int phoneNumber) async {
    final data = await http
        .get(Uri.parse('https://womena.herokuapp.com/admin/$phoneNumber'));
    print(data.body);
    print(data.statusCode);
    if (data.statusCode == 404) {
      setState(() {
        loading == false;
      });
      Get.snackbar('UnAuthorized User',
          'You are not an authorized user of picklick , Contact us for enquires');
    }
    if (data.statusCode == 200) {
      await sendOtp();
    }
  }

  Future<void> sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${phoneNumberController.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          final user =
              await FirebaseAuth.instance.signInWithCredential(credential);

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
              ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        forceResendingToken: resendToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            loading == true
                ? const SizedBox(
                    height: 5,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      color: Colors.blue,
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
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                  ),
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
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.phone),
                        prefixText: '   +91 ',
                        labelText: 'Ph No.',
                        hintText: 'Enter Your Phone Number',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            loading == true;
                          });
                          verifyUser(int.parse(phoneNumberController.text));
                        },
                        icon: loading == true
                            ? Icon(Icons.circle)
                            : const Icon(Icons.person),
                        label: loading == true
                            ? CupertinoActivityIndicator()
                            : const Text('Login'),
                        style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))))),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
