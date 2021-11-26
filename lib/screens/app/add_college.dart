import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class AddCollege extends StatefulWidget {
  const AddCollege({Key? key}) : super(key: key);

  @override
  State<AddCollege> createState() => _AddCollegeState();
}

class _AddCollegeState extends State<AddCollege> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  Future<void> addUser(String email, String name) async {
    try {
      final data = await http.post(
          Uri.parse(
            'https://womena.herokuapp.com/users/email',
          ),
          headers: {'Content-Type': "application/json"},
          body: jsonEncode({'hotel_name': name, 'email': email}));

      if (data.statusCode == 201) {
        Get.snackbar('Succesful !', 'User was succesfully added');
      }
    } catch (e) {
      Get.snackbar('Unexpected Error', '$e');
    }
  }

  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                loading == true
                    ? const LinearProgressIndicator(
                        backgroundColor: Colors.white,
                      )
                    : const SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(
                        'Add College',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: const [
                          Text('All fields are manditory ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey,
                                  letterSpacing: 0.5)),
                          Text('*',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.red))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: const CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: SizedBox(
                    height: 45,
                    child: TextFormField(
                      validator: (value) {
                        if (value == '' || value == null) {
                          return 'Please enter user email';
                        } else {
                          return null;
                        }
                      },
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: SizedBox(
                    height: 45,
                    child: TextFormField(
                      validator: (value) {
                        if (value == '' || value == null) {
                          return 'Please enter user name';
                        } else {
                          return null;
                        }
                      },
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter User Name',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      await addUser(
                        emailController.text,
                        nameController.text,
                      );
                    }
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Add College'),
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
