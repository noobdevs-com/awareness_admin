import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

Future<void> addCollege(String username, int phoneno) async {
  try {
    http.Response response = await http.post(
      Uri.parse("https://womena.herokuapp.com/users"),
      body: jsonEncode({
        "username": username,
        "phone_number": phoneno,
      }),
      headers: {
        "Content-type": "application/json",
      },
    );
    if (response.statusCode == 201) {
      Get.snackbar("Success", "College has been added.");
    } else {
      Get.snackbar("oops...", "Please try again");
    }
  } catch (e) {
    Get.snackbar("oops...", "Please try again");
  }
}
