import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:lost_and_foud/auth/login_page.dart';
import 'package:lost_and_foud/bloc/counter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:bloc/bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LostAndFound());
}
// / Store definition

class LostAndFound extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  static const String _title = 'Lost and Found app';

  LostAndFound({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: _fbApp,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print("you have an error ${snapshot.error.toString()}");
                return const Text(
                    "Network Error, Please connect to the Internet");
              } else if (snapshot.hasData) {
                return const LoginPage();
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),

        // MyStatefulWidget(),
      ),
    );
  }
}
