import 'package:CookEasy/view/screen/new_password_screen.dart';
import 'package:CookEasy/view/widget/custom_Text_Form_fild.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iconly/iconly.dart';

class PasswordRecoveryScreen extends StatelessWidget {
  const PasswordRecoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Recuperar contrasena',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text("Pon tu mail para recuperarla",
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            CostomTextFormFild(
              hint: "Mail o telefono",
              prefixIcon: IconlyBroken.message,
            ),
            CustomButton(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewPasswordScreen(),
                      ));
                },
                text: "Siguiente"),
          ]),
        ),
      ),
    );
  }
}
