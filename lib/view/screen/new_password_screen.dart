import 'package:CookEasy/view/widget/custom_Text_Form_fild.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iconly/iconly.dart';

import '../../constants/colors.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({Key? key}) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool obscure = true;

  //The validator key related to the text field
  bool _contansANumber = false;
  final bool _numberofDigits = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Restaura la contrasena",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Introduce una nueva",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              CostomTextFormFild(
                onChanged: (value) {
                  setState(() {
                    _contansANumber = value.length < 6 ? false : true;
                  });
                },
                obscureText: obscure,
                hint: "Contrasena",
                prefixIcon: IconlyBroken.lock,
                suffixIcon:
                    obscure == true ? IconlyBroken.show : IconlyBroken.hide,
                onTapSuffixIcon: () {
                  setState(() {});
                  obscure = !obscure;
                },
              ),
              passwordTerms(
                  ateast6: _contansANumber, contains: _contansANumber),
              CustomButton(onTap: () {}, text: "Hecho"),
            ],
          ),
        ),
      ),
    );
  }

  // Part about password terms
  passwordTerms({
    required bool contains,
    required bool ateast6,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Tiene que contener :",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: mainText),
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
                  ateast6 == false ? outline : const Color(0xFFE3FFF1),
              child: Icon(
                Icons.done,
                size: 12,
                color: ateast6 == false ? SecondaryText : primary,
              ),
            ),
            Text(
              "  Almenos 6 caracteres",
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
              "  Contiene un numero",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: contains == false ? SecondaryText : mainText),
            )
          ],
        ),
      ],
    );
  }
}
