import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSDetails extends StatefulWidget {
  final String sosId;
  final String uid;
  const SOSDetails({Key? key, required this.sosId, required this.uid})
      : super(key: key);

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<SOSDetails> {
  dynamic event;
  dynamic user;
  bool loading = false;
  String? userName;
  String? userImg;

  Future<void> getEvent() async {
    setState(() {
      loading = true;
    });
    try {
      DocumentSnapshot response = await FirebaseFirestore.instance
          .collection('sos')
          .doc(widget.sosId)
          .get();
      event = response.data();
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> updateStatus(String status) async {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.sosId)
          .update({"status": status});
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
    }
    setState(() {
      loading = false;
    });
  }

  Future getUser(userid) async {
    setState(() {
      loading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .get()
          .then((value) {
        var data = value.data()!;
        setState(() {
          userName = data['name'];
          userImg = data['profile_img'];
        });
      }).whenComplete(() {
        setState(() {
          loading = false;
        });
      });
    } catch (e) {
      Get.snackbar("oops...", "Unable to get event");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getEvent();
    getUser(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SOS Details",
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
            )),
      ),
      body: loading
          ? const SizedBox(
              height: 250,
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 280,
                  width: MediaQuery.of(context).size.width,
                  child: event['images'].isEmpty
                      ? const Center(
                          child: Text("User just provided location."))
                      : ImageSlideshow(
                          autoPlayInterval: 3000,
                          isLoop: true,
                          children: event['images']
                              .map<Widget>(
                                (img) => Container(
                                  height: 280,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    image: DecorationImage(
                                        image: NetworkImage(img)),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ReadMoreText(
                    event['description'],
                    trimLines: 5,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    colorClickableText: Colors.grey,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Read more',
                    trimExpandedText: 'Collaspe',
                    moreStyle:
                        const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                loading
                    ? Container(
                        height: 5,
                      )
                    : Card(
                        child: ListTile(
                          minVerticalPadding: 20,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                userImg == null ? null : NetworkImage(userImg!),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Requested by',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                userName!,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                            ],
                          ),
                        ),
                      ),

                // Google Maps
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      String url =
                          'https://www.google.com/maps/search/${event["coordinates"][0]},${event["coordinates"][1]}';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        await launch(url);
                      }
                    },
                    child: const Text(
                      "See Location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
