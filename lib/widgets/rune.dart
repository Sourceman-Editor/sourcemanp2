import 'package:flutter/material.dart';
import 'package:sourcemanv2/config.dart';

class RuneWidget extends StatelessWidget {
  const RuneWidget({
    required this.ch,
    required this.isSelected,
    super.key,
  });

  final String ch;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    List<BoxShadow> shadows = [];
    Color? color;
    if (isSelected) {
      shadows.add(Configuration.highlightBoxShadow);
      color = Configuration.highlightColor;
    }
    return Container(
      decoration: BoxDecoration(
        boxShadow: shadows,
        color: color,
      ),
      child: RichText(
        text: TextSpan(
          text: ch, 
          style: Configuration.defaultTextStyle,
        )
      )
    );
  }
}


