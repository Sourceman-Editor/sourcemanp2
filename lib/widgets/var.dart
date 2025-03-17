import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sourcemanv2/config.dart';
import 'package:sourcemanv2/datatype.dart';
import 'package:sourcemanv2/event.dart';
import 'package:sourcemanv2/managers/env_var_manager.dart';

class VarWidget extends StatefulWidget {
  final EventManager events;
  final EnvVarManager manager;
  final String varKey;

  const VarWidget({
    required this.varKey, 
    required this.events, 
    required this.manager,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _VarWidgetState();

}

class _VarWidgetState extends State<VarWidget> {
  String text = "?";
  // static bool cursorDragging = false;
  StreamSubscription? profileOpenSubscription;


  void _loadValue() {
    EnvVar? v = widget.manager.findVarByKey("default", widget.varKey);
    setState(() {
      text = v?.value?? "?";
    });
  }

  void _changeValue(ProfileOpenEvent event) {
    EnvVar? v = widget.manager.findVarByKey(event.profileKey, widget.varKey);
    setState(() {
      text = v?.value?? "?";
    });
  }

  @override
  void initState() {
    profileOpenSubscription = widget.events.listen<ProfileOpenEvent>(_changeValue);
    _loadValue();
    super.initState();
  }

  @override
  void dispose() {
    profileOpenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        cursor: WidgetStateMouseCursor.clickable,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Configuration.defaultVarColor,
                border: Configuration.defaultVarBorder,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: RichText(
                  text: TextSpan(
                    text: text,
                    style: Configuration.defaultTextStyle,
                  )
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
      onPanDown: (DragDownDetails details) {
        
      },
      onTapCancel: () {
        
      },
      onPanEnd: (DragEndDetails details) {
        
      }
    );
  }
}