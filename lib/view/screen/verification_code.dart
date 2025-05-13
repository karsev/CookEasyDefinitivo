import 'dart:async';
import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/home_screen.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationCode extends StatefulWidget {
  const VerificationCode({Key? key}) : super(key: key);

  @override
  _VerificationCodeState createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  User? user;
  bool isVerified = false;
  bool canResendEmail = false;
  late Timer verificationTimer;
  late Timer countdownTimer;
  int secondsRemaining = 3 * 60 + 10; // 3 minutes and 10 seconds

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null && !user!.emailVerified) {
      sendVerificationEmail();
      startVerificationCheck();
      startCountdown();
    }
  }

  @override
  void dispose() {
    verificationTimer.cancel();
    countdownTimer.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user!.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 30));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending email verification')),
      );
    }
  }

  void startVerificationCheck() {
    verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  Future<void> checkEmailVerified() async {
    await user!.reload();
    setState(() {
      isVerified = user!.emailVerified;
    });

    if (isVerified) {
      verificationTimer.cancel();
      countdownTimer.cancel();
    }
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get timerText {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    isVerified ? "Email Verified!" : "Verify Your Email",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      isVerified
                          ? "Your email has been successfully verified."
                          : "We've sent a verification link to your email. Please check your inbox and click the link to verify your email address.",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (!isVerified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Verifying in ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          timerText,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Secondary),
                        ),
                      ],
                    ),
                ],
              ),
              Column(
                children: [
                  if (!isVerified)
                    CustomButton(
                      onTap: canResendEmail ? sendVerificationEmail : () {},
                      text: "Resend Email",
                      color: canResendEmail ? Colors.blue : Colors.grey,
                    ),
                  if (isVerified)
                    CustomButton(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      },
                      text: "Continue",
                      color: primary,
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
