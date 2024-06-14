import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_image_storage.dart';

class OtpScreen extends StatefulWidget {
  String verificationid;

  OtpScreen({super.key, required this.verificationid});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Screen"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              controller: otpController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter the OTP",
                suffixIcon: const Icon(Icons.phone),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  PhoneAuthCredential credential =
                      await PhoneAuthProvider.credential(
                          verificationId: widget.verificationid,
                          smsCode: otpController.text.toString());
                  FirebaseAuth.instance.signInWithCredential(credential).then((Value){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>const ImgStorage()));
                  });
                } catch (ex) {
                  log(ex.toString() as num);
                }
              },
              child: const Text("OTP"))
        ],
      ),
    );
  }
}
