import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:lost_and_foud/auth/login_page.dart';
// import 'package:lost_and_foud/homePage.dart';

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

class RegisterPage extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (email, password)
  final Function(String? email, String? password)? onSubmitted;

  const RegisterPage({this.onSubmitted, Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late String email, fullName, phone, password, confirmPassword;
  String? emailError, passwordError, fullNameError, phoneError;
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    fullName = "";
    phone = "";
    email = "";
    password = "";
    confirmPassword = "";

    emailError = null;
    passwordError = null;
    fullNameError = null;
    passwordError = null;
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
      fullNameError = null;
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

    if (fullName.isEmpty) {
      setState(() {
        fullNameError = "Please enter your Full Name";
      });
      isValid = false;
    }
    if (phone.isEmpty) {
      setState(() {
        phoneError = "Please enter a Phone Number";
      });
      isValid = false;
    }
    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        passwordError = "Please enter a Password";
      });
      isValid = false;
    }
    if (password != confirmPassword) {
      setState(() {
        passwordError = "Passwords do not match";
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
      DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("users");
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      Map<String, String> user = {
        "name": fullName,
        "phone": phone,
        "email": email,
        "password": password
      };

      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'email',
            isEqualTo: email,
          )
          .get();
      final List<DocumentSnapshot> resultDocument = result.docs;
      if (resultDocument.length > 0) {
        setState(() {
          emailError = "Email is already Registered";
        });
      } else {
        users.add(user);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ));
      }

      // if (onSubmitted != null) {
      //   onSubmitted!(email, password);
      // }
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              SizedBox(height: screenHeight * .04),
              const Text(
                "Create Account,",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * .01),
              Text(
                "Sign up to get started!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(.6),
                ),
              ),
              SizedBox(height: screenHeight * .11),
              InputField(
                onChanged: (value) {
                  setState(() {
                    fullName = value;
                  });
                },
                labelText: "Full Name",
                errorText: fullNameError,
                // keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                // autoFocus: true,
              ),
              SizedBox(height: screenHeight * .025),
              InputField(
                onChanged: (value) {
                  setState(() {
                    phone = value;
                  });
                },
                labelText: "Phone No.",
                errorText: phoneError,
                // keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                // autoFocus: true,
              ),
              SizedBox(height: screenHeight * .025),
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
                labelText: "Password",
                errorText: passwordError,
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: screenHeight * .025),
              InputField(
                onChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                },
                onSubmitted: (value) => submit(),
                labelText: "Confirm Password",
                errorText: passwordError,
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(
                height: screenHeight * .075,
              ),
              FormButton(
                text: "Sign Up",
                onPressed: () => {
                  submit(),
                },
              ),
              SizedBox(
                height: screenHeight * .06,
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: const TextSpan(
                    text: "I'm already a member, ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Sign In",
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
