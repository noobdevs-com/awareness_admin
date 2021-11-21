import 'package:awareness_admin/services/college.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddCollege extends StatefulWidget {
  const AddCollege({Key? key}) : super(key: key);

  @override
  State<AddCollege> createState() => _AddCollegeState();
}

class _AddCollegeState extends State<AddCollege> {
  final TextEditingController usernameTextEditingController =
      TextEditingController();

  final TextEditingController phoneTextEditingController =
      TextEditingController();

  bool loading = false;

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              loading == true
                  ? const LinearProgressIndicator()
                  : const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    controller: usernameTextEditingController,
                    decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter username',
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
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                        labelText: 'Phone No.',
                        hintText: 'Enter user phone number',
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
                  if (usernameTextEditingController.text == "" ||
                      phoneTextEditingController.text == "") {
                    return Get.snackbar("oops", "please fill all the fields.");
                  }
                  if (phoneTextEditingController.text.length < 10 ||
                      phoneTextEditingController.text.length > 10) {
                    return Get.snackbar("oops", "please enter valid number");
                  }
                  setState(() {
                    loading = true;
                  });
                  await addCollege(
                    usernameTextEditingController.text,
                    int.parse(phoneTextEditingController.text),
                  );
                  usernameTextEditingController.clear();
                  phoneTextEditingController.clear();
                  setState(() {
                    loading = false;
                  });
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
    );
  }
}
