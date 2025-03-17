import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sourcemanv2/config.dart';
import 'package:sourcemanv2/event.dart';

class CursorSlotController {
  late void Function() blinkCursor;
}

class CursorSlot extends StatefulWidget {
  const CursorSlot({
    required this.events,
    required this.controller,
    required this.defaultBlink,
    super.key
  });

  final EventManager events;
  final CursorSlotController controller;
  final bool defaultBlink;

  @override
  State<StatefulWidget> createState() => _CursorSlotState();
}

class _CursorSlotState extends State<CursorSlot> {
  Timer? cursorTimer;
  BoxBorder? currBorder;
  StreamSubscription? cursorEventSubscription;
  Color color = Configuration.hideCursorColor;
  
  @override
  void initState() {
    currBorder = Configuration.defaultBorder;
    widget.controller.blinkCursor = blinkCursor;
    super.initState();
    if (widget.defaultBlink == true) {
      blinkCursor();
    }
  }

  @override
  void dispose() {
    cursorTimer?.cancel();
    cursorEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.blinkCursor = blinkCursor;
    return Container(
      decoration: BoxDecoration(
        // color: color,
        border: currBorder,
      ),
      child: const SizedBox(
        height: Configuration.cursorHeight,
        width: 0,
      )
    );
  }

  void _hideCursor(CursorClickEvent e) {
    cursorEventSubscription?.cancel();
    cursorTimer?.cancel();
    cursorTimer = null;
    // if (mounted == false) {
    //   return;
    // }
    setState(() {
      // color = Configuration.hideCursorColor;
      currBorder = Configuration.defaultBorder;
    });
    
  }

  void blinkCursor() {
    // if (mounted == false) {
    //   return;
    // }
    cursorEventSubscription?.cancel();
    widget.events.emit<CursorClickEvent>(CursorClickEvent());
    cursorEventSubscription = widget.events.listen<CursorClickEvent>(_hideCursor);
    setState(() {
      currBorder = Configuration.cursorBorder;
    });
    cursorTimer ??= Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (currBorder == Configuration.cursorBorder) {
        setState(() {
          currBorder = Configuration.defaultBorder;
        });
      } else {
        setState(() {
          currBorder = Configuration.cursorBorder;
        });
      }
    });
  }
}
