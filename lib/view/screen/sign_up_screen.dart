import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/sign_in_screen.dart'; // Importa la pantalla de inicio de sesión
import 'package:CookEasy/view/widget/custom_Text_Form_fild.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool obscure =
      true; // Cambiado a 'true' para ocultar la contraseña por defecto
  final key = GlobalKey<FormState>();
  bool _containsANumber = false;
  bool _numberofDigits = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(77, 67, 58, 1),
        extendBody: true,
        body: SingleChildScrollView(
          reverse: true,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Form(
                    key: key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Bienvenid@",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "Introduce tu cuenta",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        CostomTextFormFild(
                          controller: emailController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Introduce tu mail";
                            } else {
                              return null;
                            }
                          },
                          hint: "Mail o telefono",
                          prefixIcon: IconlyBroken.message,
                        ),
                        CostomTextFormFild(
                          controller: passwordController,
                          onChanged: (value) {
                            setState(() {
                              _numberofDigits = value.length >= 6;
                              _containsANumber = RegExp(r'\d').hasMatch(value);
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Introduce tu contrasena";
                            } else if (!_numberofDigits) {
                              return "La contraseña debe tener al menos 6 caracteres";
                            } else if (!_containsANumber) {
                              return "La contraseña debe contener al menos un número";
                            }
                            return null;
                          },
                          obscureText: obscure,
                          hint: "Contraseña",
                          prefixIcon: IconlyBroken.lock,
                          suffixIcon: obscure
                              ? IconlyBroken.hide
                              : IconlyBroken
                                  .show, // Cambiado el icono según el estado de la visibilidad de la contraseña
                          onTapSuffixIcon: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    onTap: () async {
                      if (key.currentState!.validate()) {
                        try {
                          // Intentar registrar el usuario con Firebase Auth
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          // Envía el correo de verificación
                          await userCredential.user!.sendEmailVerification();
                          // Muestra un mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Se ha enviado un correo de verificación a ${emailController.text}'),
                            ),
                          );
                          // Navega a la pantalla de inicio de sesión
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        } catch (e) {
                          // Manejar errores de registro
                          print('Error al registrarse: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al registrarse: $e'),
                            ),
                          );
                        }
                      }
                    },
                    text: "Registrarse",
                  ),
                  passwordTerms(
                    contains: _containsANumber,
                    ateast6: _numberofDigits,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  passwordTerms({
    required bool contains,
    required bool ateast6,
  }) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor:
                  ateast6 == false ? outline : const Color(0xFFE3FFF1),
              child: Icon(
                Icons.done,
                size: 12,
                color: ateast6 == false ? SecondaryText : primary,
              ),
            ),
            Text(
              "  Minimo 6 caracteres",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: ateast6 == false ? SecondaryText : mainText),
            )
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor:
                  contains == false ? outline : const Color(0xFFE3FFF1),
              child: Icon(
                Icons.done,
                size: 12,
                color: contains == false ? SecondaryText : primary,
              ),
            ),
            Text(
              "  Contiene un número",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: contains == false ? SecondaryText : mainText),
            )
          ],
        ),
      ],
    );
  }
}
