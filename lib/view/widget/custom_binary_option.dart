import 'package:CookEasy/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomBinaryOption extends StatefulWidget {
  CustomBinaryOption({
    Key? key,
    this.textLeft = "Left",
    this.textRight = "Right",
    this.onTapLeft,
    this.onTapRight,
    this.textStyle,
  }) : super(key: key);
  final String textLeft;
  final String textRight;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final TextStyle? textStyle;

  @override
  State<CustomBinaryOption> createState() => _CustomBinaryOptionState();
}

class _CustomBinaryOptionState extends State<CustomBinaryOption> {
  bool lr = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        color: Colors.white,
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    lr = false;
                  });
                  widget.onTapLeft?.call(); // Ejecuta la función onTapLeft si no es nula
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.textLeft,
                      style: widget.textStyle?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: lr == false ? mainText : SecondaryText,
                          ) ??
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: lr == false ? mainText : SecondaryText),
                    ),
                    Container(
                      height: lr == false ? 3 : 1,
                      color: lr == false ? primary : SecondaryText,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    lr = true;
                  });
                  widget.onTapRight?.call(); // Ejecuta la función onTapRight si no es nula
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.textRight,
                      style: widget.textStyle?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: lr == true ? mainText : SecondaryText,
                          ) ??
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: lr == true ? mainText : SecondaryText),
                    ),
                    Container(
                      height: lr == true ? 3 : 1,
                      color: lr == true ? primary : SecondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}