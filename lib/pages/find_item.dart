import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:url_launcher/url_launcher.dart';

class FindItem extends StatefulWidget {
  FindItem({Key? key}) : super(key: key);

  @override
  State<FindItem> createState() => _FindItemState();
}

int selectedTab = 0;
const List<String> tabList = <String>[
  'Mobile',
  'Bag',
  'Money',
  'Documents',
  'Keys',
  'Other',
];

class _FindItemState extends State<FindItem> {
  CollectionReference recipes =
      FirebaseFirestore.instance.collection('lost_items');

  @override
  void initState() {
    super.initState();
  }

  void openMap(latitude, longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabList.length,
      child: Scaffold(
          backgroundColor: Colors.blue,
          appBar: AppBar(
            toolbarHeight: 48,
            automaticallyImplyLeading: false,
            elevation: 8,
            titleSpacing: 0,
            title: TabBar(
              indicatorColor: Colors.white,
              isScrollable: true,
              tabs: tabList
                  .map((tab) => Tab(
                        child: Text(tab),
                      ))
                  .toList(),
              onTap: (index) {
                print(index);
                setState(() {
                  selectedTab = index;
                });
              },
            ),
          ),
          body: Container(
            color: Colors.white,
            child: TabBarView(children: <Widget>[
              for (var i = 0; i < tabList.length; i++) ...[
                FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('lost_items')
                        .where('type', isEqualTo: tabList[i])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // <3> Retrieve `List<DocumentSnapshot>` from snapshot
                        final List<DocumentSnapshot> documents =
                            snapshot.data!.docs;
                        return ListView(
                            children: documents
                                .map((doc) => Column(
                                      children: [
                                        Card(
                                            shadowColor: Colors.black87,
                                            elevation: 5,
                                            margin: EdgeInsets.fromLTRB(
                                                10, 30, 10, 10),
                                            child: Container(
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                          children: <Widget>[
                                                            Image.network(
                                                              // "https://res.cloudinary.com/blue-sky/image/upload/v1676667400/sample/i1_grd9fi.jpg",
                                                              doc['imag_url'],
                                                              // height: 100,
                                                              width: 150,
                                                              height: 160,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          ]),
                                                    ),
                                                    Expanded(
                                                        child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                              "${doc['item']}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            )),
                                                            doc['lost']
                                                                ? GFButton(
                                                                    onPressed:
                                                                        () {},
                                                                    text:
                                                                        "Lost",
                                                                    shape: GFButtonShape
                                                                        .pills,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .yellow,
                                                                    textStyle: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                  )
                                                                : GFButton(
                                                                    onPressed:
                                                                        () {},
                                                                    text:
                                                                        "Found",
                                                                    shape: GFButtonShape
                                                                        .pills,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .green,
                                                                    textStyle: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                  ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                              "${doc['description']}.",
                                                              style: TextStyle(
                                                                  height: 1.2,
                                                                  fontSize: 16),
                                                            ))
                                                          ],
                                                        ),
                                                        SizedBox(height: 10),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                              "Phone: ${doc['phone']},",
                                                              style: TextStyle(
                                                                  height: 1.2,
                                                                  fontSize: 16),
                                                            ))
                                                          ],
                                                        ),
                                                        SizedBox(height: 10),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: Text(
                                                                    "Posted By ")),
                                                            Expanded(
                                                                child: Text(
                                                              doc['posted_by'],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                            ))
                                                          ],
                                                        ),
                                                        SizedBox(height: 10),
                                                        Container(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              openMap(
                                                                  doc['address']
                                                                      ['lat'],
                                                                  doc['address']
                                                                      ['long']);
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 10,
                                                                  child: Text(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    "Track item",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        SizedBox(
                                                                      width: 1,
                                                                    )),
                                                                Expanded(
                                                                  flex: 6,
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            style: ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all<Color>(Colors
                                                                            .blue),
                                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                    side: BorderSide(
                                                                        color: Colors
                                                                            .blue)))),
                                                          ),
                                                        ),
                                                      ],
                                                    ))

                                                    // ignore: unnecessary_new
                                                  ],
                                                ))),
                                      ],
                                    ))
                                .toList());
                      } else if (snapshot.hasError) {
                        return Text('It${Error}!');
                      }
                      return Text("");
                    })

                // FirebaseAnimatedList(
                //   query: _ref,
                //   itemBuilder: (BuildContext context, DataSnapshot snapshot,
                //       animation, int index) {
                //     // Map lost_items2 = snapshot.value;
                //     var lost_items =
                //         Map<dynamic, dynamic>.from(snapshot.value! as Map);
                //     print(lost_items.length);

                //   },
                // ),
              ]
            ]),
          )),
    );
  }
}
