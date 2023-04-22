import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_foud/home_layout.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloudinary/cloudinary.dart';
// import 'addItem.dart';

class AddItem extends StatefulWidget {
  AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

const List<String> list = <String>[
  'Mobile',
  'Bag',
  'Money',
  'Documents',
  'Keys',
  'Other',
];

class _AddItemState extends State<AddItem> {
  PageController _pageController = PageController();
  late String selected;
  final cloudinary = Cloudinary.signedConfig(
    apiKey: "188655986618161",
    apiSecret: "NhcWeFvdk1zcsO3QqpuzOHl5aCA",
    cloudName: "blue-sky",
  );
  final DatabaseReference reference =
      FirebaseDatabase.instance.reference().child('lost_items');
  bool submmited = false;
  String dropdownValue = list.first;
  String holder = '';
  String name = '';
  bool nameError = false;
  String phone = '';
  bool phoneError = false;
  String description = '';
  String locationText = "Set Current Location";
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  bool imagepicked = false;
  bool isPicked = true;
  bool saveingLocation = false;
  String itemType = 'lost';
  late Position _currentPosition;

  void _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = image;
        print(pickedImage);
        String file = pickedImage!.path;
        print(file);
        Image.file(File(pickedImage!.path));
        imagepicked = true;
      });
    }
  }

  void resetErrorText() {
    setState(() {
      nameError = false;
      phoneError = false;
      isPicked = false;
    });
  }

  bool validate() {
    resetErrorText();

    RegExp phoneExp =
        RegExp(r"^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$");

    bool isValid = true;
    if (name.isEmpty) {
      setState(() {
        nameError = true;
      });
      isValid = false;
    }
    if (phone.isEmpty) {
      setState(() {
        phoneError = true;
      });
      isValid = false;
    } else if (!phoneExp.hasMatch(phone)) {
      setState(() {
        phoneError = true;
      });
      isValid = false;
    }
    if (!imagepicked) {
      setState(() {
        isPicked = false;
      });
      isValid = false;
    }

    return isValid;
  }

  void clearPage() {
    setState(() {
      submmited = false;
      dropdownValue = list.first;
      holder = '';
      name = '';
      nameError = false;
      phone = '';
      phoneError = false;
      description = '';
      locationText = "Set Current Location";
      pickedImage = null;
      imagepicked = false;
      isPicked = true;
      saveingLocation = false;
      itemType = 'lost';
    });
  }

  void _submit() async {
    if (validate()) {
      setState(() {
        submmited = true;
        if (imagepicked) {
          isPicked = true;
        }
      });
      final DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('lost_items');

      print(name);
      print(description);
      print(dropdownValue);

      List<int> imageBytes = await pickedImage!.readAsBytes();
      final response = await cloudinary.upload(
          file: pickedImage!.path,
          fileBytes: imageBytes,
          resourceType: CloudinaryResourceType.image,
          folder: "sample",
          fileName: 'flutter',
          progressCallback: (count, total) {});

      if (response.isSuccessful) {
        print('Get your image from with ${response.secureUrl}');
        String? newkey = reference.push().key; // That is your unique key!
        String? url = response.secureUrl;
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        CollectionReference lost_items =
            FirebaseFirestore.instance.collection('lost_items');

        final prefs = await SharedPreferences.getInstance();
        String? posterName = prefs.getString('name');
        String? email = prefs.getString('email');
        await lost_items.add({
          "address": {
            "long": _currentPosition.longitude,
            "lat": _currentPosition.latitude
          },
          "description": description,
          'phone': phone,
          "imag_url": url,
          "item": name,
          "poster_id": "ACMLSCNALN",
          "type": dropdownValue,
          "lost": itemType == "lost" ? false : true,
          "posted_by": posterName,
          "resolved": false,
          "email": email
        });
        clearPage();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeLayout(),
            ));
        // _pageController.animateToPage(1,
        //     duration: const Duration(microseconds: 1000), curve: Curves.easeIn);
      }
    }
  }

  _getCurrentLocation() async {
    await Geolocator.requestPermission();

    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        print(position);
        _currentPosition = position;
        locationText = "Location Saved";
        saveingLocation = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        locationText = "Error! Try Again";
      });
    });
    print("position");
    saveingLocation = false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: const BoxDecoration(),
        child: Center(
            child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: [
                  Flexible(
                    child: RadioListTile(
                      title: Text("Lost"),
                      value: "lost",
                      groupValue: itemType,
                      onChanged: (value) {
                        setState(() {
                          itemType = value.toString();
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: RadioListTile(
                      title: Text("Found"),
                      value: "found",
                      groupValue: itemType,
                      onChanged: (value) {
                        setState(() {
                          itemType = value.toString();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                  margin: EdgeInsets.fromLTRB(23, 0, 20, 0),
                  child: 'Item type'.text.start.lg.bold.make()),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: DropdownButtonHideUnderline(
                child: GFDropdown(
                  padding: const EdgeInsets.all(15),
                  borderRadius: BorderRadius.circular(5),
                  focusColor: Colors.blue,
                  border: const BorderSide(color: Colors.black12, width: 1),
                  dropdownButtonColor: Colors.white,
                  value: dropdownValue,
                  onChanged: (value) {
                    setState(() {
                      if (value == "Mobile") {
                        dropdownValue = "Mobile";
                      } else if (value == "keys") {
                        dropdownValue = "keys";
                      } else if (value == "Bag") {
                        dropdownValue = "Bag";
                      } else if (value == "Documents") {
                        dropdownValue = "Documents";
                      } else if (value == "Money") {
                        dropdownValue = "Money";
                      } else if (value == "Other") {
                        dropdownValue = "Other";
                      }
                    });
                  },
                  items: list
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                  margin: EdgeInsets.fromLTRB(23, 0, 20, 10),
                  child: 'Item Name'.text.start.lg.bold.make()),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(23, 0, 20, 10),
                child: TextField(
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter item name',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: nameError ? Colors.red : Colors.grey)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.blue))))),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.fromLTRB(23, 0, 0, 10),
              child: Text(
                nameError ? "Name is Invalid" : '',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                  margin: EdgeInsets.fromLTRB(23, 0, 20, 10),
                  child: 'Your phone number'.text.start.lg.bold.make()),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(23, 0, 20, 10),
                child: TextField(
                    onChanged: (value) {
                      setState(() {
                        phone = value;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter phone number',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: phoneError ? Colors.red : Colors.grey)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.blue))))),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.fromLTRB(23, 0, 0, 10),
              child: Text(
                nameError ? "Phone is Invalid" : '',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                  margin: EdgeInsets.fromLTRB(23, 0, 20, 10),
                  child: 'Description'.text.start.lg.bold.make()),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(23, 0, 20, 0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                // controller: textarea,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                    hintText: "I found this item ...",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.blue))),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                  margin: EdgeInsets.fromLTRB(23, 10, 20, 10),
                  child: GFButton(
                    onPressed: () {
                      _getCurrentLocation();
                      setState(() {
                        locationText = "Saving Location...";
                      });
                    },
                    // text: locationText,
                    child: saveingLocation
                        ? LoadingAnimationWidget.inkDrop(
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(locationText),
                    shape: GFButtonShape.standard,
                  )),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                  margin: EdgeInsets.fromLTRB(23, 0, 20, 10),
                  child: Center(child: 'Image'.text.start.lg.bold.make())),
            ),
            if (imagepicked)
              Image.file(
                File(pickedImage!.path),
                height: MediaQuery.of(context).size.width * 0.65,
                width: MediaQuery.of(context).size.width * 0.75,
                scale: 0.7,
                fit: BoxFit.cover,
              ),
            SizedBox(
                width: double.infinity,
                child: Container(
                  margin: EdgeInsets.fromLTRB(23, 5, 20, 10),
                  child: imagepicked
                      ? GestureDetector(
                          onTap: () {
                            _takePicture();
                          },
                          child: Center(
                              child: 'Change Image'
                                  .text
                                  .start
                                  .xl
                                  .blue600
                                  .underline
                                  .make()),
                        )
                      : IconButton(
                          iconSize: 50,
                          color: Colors.blue,
                          onPressed: () {
                            _takePicture();
                          },
                          icon: Icon(
                            Icons.photo_camera,
                          ),
                        ),
                )),
            Text(
              !isPicked ? 'Please pick an image' : '',
              style: TextStyle(color: Colors.red),
            ),
            GFButton(
              onPressed: () {
                _submit();
              },
              // text: locationText,
              child: submmited
                  ? LoadingAnimationWidget.inkDrop(
                      color: Colors.white,
                      size: 20,
                    )
                  : Text("Submit"),
              shape: GFButtonShape.standard,
            )
          ],
        )),
      ),
    );
  }
}
