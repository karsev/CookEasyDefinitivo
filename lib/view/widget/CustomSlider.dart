import 'package:CookEasy/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider({Key? key}) : super(key: key);

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double slider = 30;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Tiempo de cocinado ",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              "( en minutos )",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "< 10",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: primary),
                  ),
                  Text(
                    "30",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: primary),
                  ),
                  Text(
                    "> 50",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: primary),
                  ),
                ],
              ),
            ),
            Slider(
                divisions: 2,
                activeColor: primary,
                thumbColor: primary,
                max: 60,
                min: 10,
                value: slider,
                onChanged: (value) {
                  setState(() {
                    slider = value;
                  });
                })
          ],
        )
      ],
    );
  }
}
