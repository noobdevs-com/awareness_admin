import 'dart:convert';

import 'package:awareness_admin/constants/value_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  final TextEditingController phNoController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  Future<void> addUser(int phoneNumber, String name) async {
    try {
      final data = await http
          .post(
              Uri.parse(
                'https://womena.herokuapp.com/users',
              ),
              headers: {'Content-Type': "application/json"},
              body: jsonEncode({'username': name, 'phone_number': phoneNumber}))
          .whenComplete(() {
        setState(() {
          loading = false;
        });
      });
      print(data.body);

      if (data.statusCode == 201) {
        Get.snackbar('Succesful !', 'User was succesfully added');
      }
    } catch (e) {
      Get.snackbar('Unexpected Error', '$e');
      setState(() {
        loading = false;
      });
    }
  }

  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add College'),
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
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
                        backgroundColor: Color(0xFF29357c),
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
                          return 'Please enter user Phone Number';
                        } else {
                          return null;
                        }
                      },
                      controller: phNoController,
                      decoration: kTextFieldDecoration.copyWith(
                          labelText: 'Email',
                          hintText: 'Enter User Phone Number'),
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
                      decoration: kTextFieldDecoration.copyWith(
                          labelText: 'Name', hintText: 'Enter User Name'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 60,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ElevatedButton.icon(
                  onPressed: loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            await addUser(
                              int.parse(phNoController.text),
                              nameController.text,
                            ).whenComplete(() {
                              phNoController.clear();
                              nameController.clear();
                            });
                          }
                        },
                  icon: loading
                      ? const Text('Loading')
                      : const Icon(Icons.person),
                  label: loading
                      ? const CupertinoActivityIndicator()
                      : const Text('Add College'),
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
