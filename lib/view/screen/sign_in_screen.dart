import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/home_screen.dart';
import 'package:CookEasy/view/screen/sign_up_screen.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:CookEasy/view/widget/custom_text_form_fild.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // The variable related to showing or hiding the text
  bool obscure = true;

  // The variable key related to the txt field
  final key = GlobalKey<FormState>();

  // Controllers for email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: form,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Form(
                      key: key,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Bienvenid@!",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Pon tu cuenta, por favor",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          CostomTextFormFild(
                            controller: emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Pon tu mail";
                              } else {
                                return null;
                              }
                            },
                            hint: "Mail o telefono",
                            prefixIcon: IconlyBroken.message,
                          ),
                          CostomTextFormFild(
                            controller: passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Pon tu contraseña";
                              } else {
                                return null;
                              }
                            },
                            obscureText: obscure,
                            hint: "Contraseña",
                            prefixIcon: IconlyBroken.lock,
                            suffixIcon:
                                obscure ? IconlyBroken.show : IconlyBroken.hide,
                            onTapSuffixIcon: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _resetPassword(emailController.text);
                                },
                                child: Text(
                                  'Contraseña olvidada?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: mainText),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: "Inicia sesion",
                          color: primary,
                          onTap: () async {
                            if (key.currentState!.validate()) {
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                                if (userCredential.user != null) {
                                  // Verifica si el usuario ha verificado su correo electrónico
                                  if (userCredential.user!.emailVerified) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    // Si el usuario no ha verificado su correo electrónico, muéstrales un mensaje
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Debes verificar tu correo electrónico antes de iniciar sesión.')),
                                    );
                                    // Cerrar sesión para evitar que el usuario acceda sin verificar su correo electrónico
                                    await FirebaseAuth.instance.signOut();
                                  }
                                }
                              } catch (e) {
                                print('Error signing in: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error al iniciar sesión: $e')),
                                );
                              }
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No tienes cuenta?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: mainText),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Registrarse",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(String email) {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Se ha enviado un correo electrónico para restablecer la contraseña')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al enviar el correo electrónico: $error')),
      );
    });
  }
}
