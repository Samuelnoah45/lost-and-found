import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lost_and_foud/auth/register_page.dart';
import 'package:lost_and_foud/bloc/counter_bloc.dart';
import 'package:lost_and_foud/home_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginPage extends StatefulWidget {
  final Function(String? email, String? password)? onSubmitted;

  const LoginPage({this.onSubmitted, Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email, password;
  String? emailError, passwordError;
  String login = 'Log in';
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    email = "";
    password = "";

    emailError = null;
    passwordError = null;
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  bool validate() {
    resetErrorText();

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (email.isEmpty) {
      setState(() {
        emailError = "Please Enter an Email";
      });
      isValid = false;
    } else if (!emailExp.hasMatch(email)) {
      setState(() {
        emailError = "Email is invalid";
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = "Please enter a password";
      });
      isValid = false;
    }

    return isValid;
  }

  void submit() async {
    final prefs = await SharedPreferences.getInstance();

    if (validate()) {
      setState(() {
        login = 'Loading...';
      });
      final ref = FirebaseDatabase.instance.ref();
      // FirebaseFirestore firestore = FirebaseFirestore.instance;
      setState(() {
        emailError = null;
        passwordError = null;
      });

      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'email',
            isEqualTo: email.trim(),
          )
          .get();
      final List<DocumentSnapshot> resultDocument = result.docs;
      if (resultDocument.length < 1) {
        setState(() {
          emailError = "Invalid Credentials";
          passwordError = "Invalid Credentials";
          login = 'Log In';
        });
      } else {
        for (var i in resultDocument) {
          if (password != i['password']) {
            setState(() {
              passwordError = "Incorrect Password";
              login = 'Log In';
            });
          } else {
            // ignore: unused_local_variable
            //  MyStore store = VxState.store;
            prefs.setString('name', i['name']);
            prefs.setString('email', i['email']);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeLayout(),
                ));
          }
        }
      }
      print("Login Successful");
      if (onSubmitted != null) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            context.read<CounterBloc>().add(CounterInc(email ,password))},
          child: Text("+"),
        ),
        
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(height: screenHeight * .06),
              const Text(
                "Welcome,",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * .01),
              Text(
                "Sign in to continue!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(.6),
                ),
              ),
              SizedBox(height: screenHeight * .08),
              InputField(
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                labelText: "Email",
                errorText: emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                // autoFocus: true,
              ),
              SizedBox(height: screenHeight * .025),
              InputField(
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                onSubmitted: (val) => submit(),
                labelText: "Password",
                errorText: passwordError,
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * .04,
              ),
              FormButton(
                text: login,
                onPressed: () => {
                  submit(),
                  context.read<CounterBloc>().add(CounterInc(email ,password))
                },
              ),
              SizedBox(
                height: screenHeight * .08,
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                ),
                child: RichText(
                  text: const TextSpan(
                    text: "I'm a new user, ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  const FormButton({this.text = "", this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed as void Function()?,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: screenHeight * .02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool obscureText;
  const InputField(
      {this.labelText,
      this.onChanged,
      this.onSubmitted,
      this.errorText,
      this.keyboardType,
      this.textInputAction,
      this.autoFocus = false,
      this.obscureText = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
