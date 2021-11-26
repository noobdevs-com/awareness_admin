import 'package:awareness_admin/models/sos.dart';
import 'package:awareness_admin/screens/app/sos_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({Key? key}) : super(key: key);

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  List<SOS> sosList = [];
  bool loading = false;

  Future<void> getSOS() async {
    setState(() {
      loading = true;
    });
    try {
      QuerySnapshot ref = await FirebaseFirestore.instance
          .collection('sos')
          .orderBy("createdAt", descending: true)
          .get();
      sosList.clear();
      for (var i = 0; i < ref.docs.length; i++) {
        SOS sos = SOS(
          did: ref.docs[i].id,
          description: ref.docs[i]["description"] ?? "",
          coordinates: ref.docs[i]["coordinates"] ?? [],
          createdAt: (ref.docs[i]["createdAt"] as Timestamp).toDate(),
          images: ref.docs[i]["images"] ?? [],
        );
        sosList.add(sos);
      }
    } catch (e) {
      Get.snackbar("oops...", "Unable to get sos events");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getSOS();
  }

  @override
  void dispose() {
    super.dispose();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await getSOS();
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'SOS Events',
            style: TextStyle(color: Colors.black),
          ),
          leadingWidth: 0,
          elevation: 1,
        ),
        body: ListView.builder(
            itemCount: sosList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Card(
                    elevation: 1,
                    shadowColor: Colors.grey[300],
                    child: ListTile(
                      onTap: () => Get.to(() => SOSDetails(
                            sosId: sosList[index].did!,
                          )),
                      trailing: SizedBox(
                        width: 60,
                        child: Center(
                          child: Row(
                            children: const [
                              Text(
                                'View',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Icon(
                                Icons.arrow_right,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 2,
                          ),
                          Row(
                            children: [
                              Text(
                                DateFormat.jm().format(
                                  (sosList[index].createdAt!),
                                ),
                                style: TextStyle(
                                    color: Colors.blue.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                DateFormat.yMMMMd()
                                    .format((sosList[index].createdAt!)),
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
              );
            }),
      ),
    );
  }
}
