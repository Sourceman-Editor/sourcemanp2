import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sourcemanv2/config.dart';
import 'package:sourcemanv2/datatype.dart';
import 'package:sourcemanv2/event.dart';
import 'package:sourcemanv2/managers/env_var_manager.dart';
import 'package:sourcemanv2/widgets/cursor_slot.dart';
import 'package:sourcemanv2/widgets/rune.dart';
import 'package:sourcemanv2/parser.dart';
import 'package:sourcemanv2/widgets/var.dart';

class LineController {
  late Function setHighlight;
  late Function displayCursor;
  late Function displayCursorAt;
  late Function getRunes;
  late Function refreshAll;
  late Function removeChar;
  late Function insertChar;
  late Function getText;
  late Function getRunesLength;
}

class LineWidget extends StatefulWidget {
  final EventManager eventManager;
  final EnvVarManager envVarManager;
  final String lineText;
  final LineController controller;

  const LineWidget({
    required this.eventManager,
    required this.envVarManager,
    required this.lineText, 
    required this.controller,
    super.key
  });

  @override
  State<StatefulWidget> createState() => _LineWidgetState();

}

/*
  Need to keep number of cursor controllers 1 more than number of runes...
  Do not infinitely create new cursor controllers...
 */
class _LineWidgetState extends State<LineWidget> {
  List<Rune> runes = [];
  List<CursorSlotController> cursorControllers = [];
  final GlobalKey _rowKey = GlobalKey();
  StreamSubscription? profileOpenSubscription;

  int selectStart = 0;
  int selectEnd = 0;
  int nextBlinkCursor = -1;
  String? currentProfileKey;

  @override
  void initState() {
    _initController();

    runes = parseline(widget.lineText);
    for (int i = 0; i <= runes.length; i++) {
      cursorControllers.add(CursorSlotController());
    }
    profileOpenSubscription = widget.eventManager.listen<ProfileOpenEvent>((ProfileOpenEvent e) {currentProfileKey = e.profileKey;});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    profileOpenSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _initController();
    EventManager events = Provider.of<EventManager>(context);
    
    List<Widget> children = [];
    for (int i = 0; i < runes.length; i++) {
      Rune r = runes[i];
      bool isSelected = false;
      if (i >= selectStart && i < selectEnd) {
        isSelected = true;
      }
      if (r.isVar) {
        children.add(
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              VarWidget(
                varKey: r.varKey??"", 
                events: events,
                manager: widget.envVarManager,
                // key: UniqueKey()
              ),
              Positioned(
                left: -Configuration.cursorWidth / 2,
                child: CursorSlot(
                  key: UniqueKey(),
                  events: events, 
                  controller: cursorControllers[i],
                  defaultBlink: nextBlinkCursor == i,
                ),
              )
              
            ]
          )
        );
      } else {
        children.add(
          Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              RuneWidget(
                isSelected: isSelected,
                ch: r.ch??""
              ),
              Positioned(
                left: -Configuration.cursorWidth / 2,
                child: CursorSlot(
                  key: UniqueKey(),
                  events: events, 
                  controller: cursorControllers[i], 
                  defaultBlink: nextBlinkCursor == i,
                )
              ),
            ]
          )
        );
      }
    }

    children.add(
      CursorSlot(
        events: events, 
        controller: cursorControllers[runes.length],
        defaultBlink: nextBlinkCursor == cursorControllers.length - 1,
      )
    );

    if (nextBlinkCursor > 0) {
      nextBlinkCursor = -1;
    }

    return Container(
      padding: const EdgeInsets.only(left: -Configuration.clickOffset),
      child: Row(
        key: _rowKey,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }

  /*
    If returned index == runes.length, it means mouse is not pointing at empty space at end of line.
   */
  int _mapCursorToRuneIndex(double dx) {
    dx += Configuration.clickOffset;
    if (dx < 0) {
      return 0;
    }
    RenderObject? rowRo = _rowKey.currentContext?.findRenderObject();
    int index = 0;
    double acc = Configuration.clickOffset;
    rowRo?.visitChildren((child) {
      double size = child.semanticBounds.right - child.semanticBounds.left;
      acc += size;
      if (acc < dx) {
        index += 1;
      }
    });
    return index;
  }

  void _initController() {
    widget.controller.setHighlight = setHighlight;
    widget.controller.displayCursor = displayCursor;
    widget.controller.displayCursorAt = displayCursorAt;
    widget.controller.getRunes = getRunes;
    widget.controller.refreshAll = refreshAll;
    widget.controller.removeChar = removeChar;
    widget.controller.insertChar = insertChar;
    widget.controller.getText = getText;
    widget.controller.getRunesLength = getRunesLength;
  }
 
  void _alignCursorControllers() {
    if (cursorControllers.length > runes.length + 1) {
      int diff = cursorControllers.length - runes.length + 1;
      cursorControllers.removeRange(cursorControllers.length - diff + 2, cursorControllers.length);
    } else if (cursorControllers.length < runes.length + 1){
      int diff = runes.length + 1 - cursorControllers.length;
      for (int i = 0; i < diff; i++) {
        cursorControllers.add(CursorSlotController());
      }
    }
  }

  /*
    return rune index to parent
   */
  int displayCursor(double dx, bool? atEnd) {
    if (atEnd == true) {
      int cursorIdx = cursorControllers.length - 1;
      cursorControllers[cursorIdx].blinkCursor();  
      return cursorIdx;
    }
    int index = _mapCursorToRuneIndex(dx);
    int cursorIdx = index;
    if (cursorIdx >= cursorControllers.length) {
      cursorIdx = cursorControllers.length - 1;
      index = runes.length;
    }
    cursorControllers[cursorIdx].blinkCursor();
    return index;
  }

  void displayCursorAt(int? index) {
    if (index == null) {
      return;
    }
    nextBlinkCursor = index;
    cursorControllers[index].blinkCursor();
  }

  void setHighlight(int start, int end) {
    if (end == -1) {
      end = runes.length;
    }
    if (start != selectStart || end != selectEnd) {
      setState(() {
        selectStart = start;
        selectEnd = end;
      });
    }
  }

  int getRunesLength() {
    return runes.length;
  }

  List<Rune> getRunes(int start, int end) {
    if (end >= runes.length) {
      end = runes.length;
    }
    return runes.sublist(start, end);
  }

  void insertChar(int index, String ch) {
    Rune newRune = Rune(isVar: false, ch: ch);
    if (index < runes.length) {
      runes.insert(index, newRune);
    } else {
      runes.add(newRune);
    }
    _alignCursorControllers();
    setState(() {});
    nextBlinkCursor = index + 1;
  }

  void removeChar(index) {
    runes.removeAt(index - 1);
    cursorControllers[index - 1].blinkCursor();
    _alignCursorControllers();
    setState(() {});
  }

  void refreshAll() {
    setState(() {});
  }

  void getText(StringBuffer buffer) {
    for (Rune r in runes) {
      if (r.isVar) {
        EnvVar? envVar = widget.envVarManager.findVarByKey(currentProfileKey!, r.varKey!);
        buffer.write(envVar?.value?? "?");
      } else {
        buffer.write(r.ch);
      }
    }
  }
}