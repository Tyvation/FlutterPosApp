import 'package:flutter/material.dart';

class NavigateButton extends StatelessWidget {

  final IconData buttonIcon;
  final String buttonName;

  const NavigateButton({
    super.key,
    required this.buttonIcon,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    final myColorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [

        IconButton(
          iconSize: 25,
          icon: Icon(buttonIcon),
          color: myColorScheme.primary,
          onPressed: (){return;},
        ),

        Text(buttonName),
      ],
    );
  }
}