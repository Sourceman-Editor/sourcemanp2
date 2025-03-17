import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sourcemanv2/2d_scroll_area.dart';
import 'package:sourcemanv2/config.dart';
import 'package:sourcemanv2/datatype.dart';
import 'package:sourcemanv2/event.dart';
import 'package:sourcemanv2/managers/cursor_manager.dart';
import 'package:sourcemanv2/managers/doc_manager.dart';
import 'package:sourcemanv2/managers/env_var_manager.dart';
import 'package:sourcemanv2/managers/profile_manager.dart';
import 'package:flutter/material.dart';
import 'package:sourcemanv2/widgets/line.dart';


class DocumentWidget extends StatefulWidget {
  final String documentPath;
  final EnvVarManager envVarManager;
  final ProfileManager profileManager;
  final CursorManager cursorManager;
  final EventManager eventManager;
  const DocumentWidget({
    super.key,
    required this.documentPath,
    required this.envVarManager,
    required this.profileManager,
    required this.cursorManager,
    required this.eventManager,
  });

  @override
  State<StatefulWidget> createState() => _DocumentWidgetState();
}

class _DocumentWidgetState extends State<DocumentWidget> {
  DocManager docManager = DocManager();
  Doc document = Doc(path: "", lines: []);
  bool loading = true;
  List<LineController> lineControllers = [];
  Set<int> highlightedLines = {};
  final GlobalKey _columnKey = GlobalKey();
  late FocusNode focusNode;
  final ScrollController scroll1 = ScrollController();
  final ScrollController scroll2 = ScrollController();
  List<Widget> lines = [];

  @override
  void initState() {

    super.initState();

    docManager.loadDocFromPath(widget.profileManager, widget.envVarManager).then((doc) {
      print("load ${widget.documentPath}");
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
        if (doc != null) {
          document = doc;
        }
      });
      
    });
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: Icon(Icons.pending_actions));
    }
    lines = [];
    lineControllers = [];
    for (int i = 0; i < document.lines.length; i++) {
      _createLine(i, document.lines[i]);
    }
    if (document.lines.isEmpty) {
      _createLine(0, "");
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TwoDiScrollAreaWidget(
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                supportedDevices: const {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                child: MouseRegion(
                  cursor: WidgetStateMouseCursor.textable,
                  child: Focus(
                    focusNode: focusNode,
                    autofocus: true,
                    child: Column(
                      key: _columnKey,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: lines,
                    ),
                    onKeyEvent: (FocusNode node, KeyEvent event) {
                      if (event.runtimeType == KeyDownEvent) {
                        _handleKeyDownEvent(event);
                      } else if (event.runtimeType == KeyRepeatEvent) {
                        _handleKeyDownEvent(event);
                      } else if (event.runtimeType == KeyUpEvent) {
                        
                      }
                      return KeyEventResult.handled;
                    },
                  ),
                ),
                onPanUpdate: (DragUpdateDetails details) {
                  if (widget.cursorManager.dragging) {
                    displayCursor(details.localPosition);
                    widget.cursorManager.setSelectEnd();
                    highlightSelections();
                  }
                },
                onPanDown: (DragDownDetails details) {
                  widget.cursorManager.dragging = true;
                  displayCursor(details.localPosition);
                  widget.cursorManager.setSelectStart();
                },
                onPanEnd: (DragEndDetails details) {
                  widget.cursorManager.dragging = false;
                },
                onTapDown:(TapDownDetails details) {
                  focusNode.requestFocus();
                },
                onTapUp: (TapUpDetails details) {
                  widget.cursorManager.dragging = false;
                  resetSelections();
                },
              )
            ),
          ),
        ),
      ]
    
    );
  }

  void _createLine(int index, String content) {
    if (index < 0 || index >= lines.length) {
      LineController c = LineController();
      lineControllers.add(c);
      lines.add(
        LineWidget(
          key: UniqueKey(),
          lineText: content, 
          controller: c, 
          eventManager: widget.eventManager, 
          envVarManager: widget.envVarManager
        )
      );
    } else {
      LineController c = LineController();
      lineControllers.insert(index, c);
      lines.insert(index, 
        LineWidget(
          key: UniqueKey(),
          lineText: content, 
          controller: c, 
          eventManager: widget.eventManager, 
          envVarManager: widget.envVarManager
        )
      );
    }
  }

  void highlightSelections() {
    resetSelections();
    int startLine = widget.cursorManager.selectStartLine;
    int endLine = widget.cursorManager.selectEndLine;
    
    int startIdx = widget.cursorManager.selectStart;
    int endIdx = widget.cursorManager.selectEnd;
    if (startLine > endLine) {
      startLine = endLine;
      endLine = widget.cursorManager.selectStartLine;
      startIdx = endIdx;
      endIdx = widget.cursorManager.selectStart;
    }
    if (endLine == startLine && endLine < lineControllers.length) {
      if (startIdx > endIdx) {
        startIdx = endIdx;
        endIdx = widget.cursorManager.selectStart;
      }
      lineControllers[startLine].setHighlight(startIdx, endIdx);
      highlightedLines.add(startLine);
    } else {
      for (int i = startLine; i <= endLine; i++) {
        if (i == startLine && startLine < lineControllers.length) {
          lineControllers[i].setHighlight(startIdx, -1);
          highlightedLines.add(i);
        } else if (i == endLine && endLine < lineControllers.length) {
          lineControllers[i].setHighlight(0, endIdx);
          highlightedLines.add(i);
        } else if (i < lineControllers.length){
          lineControllers[i].setHighlight(0, -1);
          highlightedLines.add(i);
        }
      }
    }
  }

  void resetSelections() {
    for (int i in highlightedLines) {
      if (i < lineControllers.length) {
        lineControllers[i].setHighlight(0, 0);
      }
    }
  }

  void displayCursor(Offset localPosition) {
    int lineIdx = _mapCursorToLineIndex(localPosition);
    if (lineIdx < lineControllers.length) {
      LineController line = lineControllers[lineIdx];
      int runeIdx = line.displayCursor(localPosition.dx, null);
      widget.cursorManager.lineIndex = lineIdx;
      widget.cursorManager.runeIndex = runeIdx;
    } else {
      LineController line = lineControllers[lineControllers.length - 1];
      int runeIdx = line.displayCursor(localPosition.dx, true);
      widget.cursorManager.lineIndex = lineIdx;
      widget.cursorManager.runeIndex = runeIdx;
    }
  }

  int _mapCursorToLineIndex(Offset localPosition) {
    double dy = localPosition.dy;
    RenderObject? colRo = _columnKey.currentContext?.findRenderObject();
    int index = 0;
    double acc = 0;
    double lastSize = 0;
    colRo?.visitChildren((child) {
      double size = child.semanticBounds.height;
      acc += size;
      lastSize = size;
      if (acc < dy) {
        index += 1;
      }
    });
    if (dy > acc - lastSize && index > 0) {
      index += 1;
    }
    return index;
  }

  void _handleKeyDownEvent(KeyEvent event) {
    String key = event.logicalKey.keyLabel;
    switch(key) {
      case 'Backspace':
        int cursorX = widget.cursorManager.runeIndex;
        int cursorY = widget.cursorManager.lineIndex;
        if (cursorX > 0) {
          lineControllers[cursorY].removeChar(cursorX);
          widget.cursorManager.runeIndex -= 1;
          lineControllers[cursorY].displayCursorAt(widget.cursorManager.runeIndex);
        }
        break;
      case 'Home':
        // TODO pressing home should jump to first none space character
        int cursorY = widget.cursorManager.lineIndex;
        lineControllers[cursorY].displayCursor(0.0, false);
        widget.cursorManager.runeIndex = 0;
        resetSelections(); // TODO this reset selection hides cursor as well...
        break;
      case 'End':
        int cursorY = widget.cursorManager.lineIndex;
        int index = lineControllers[cursorY].displayCursor(0.0, true);
        widget.cursorManager.runeIndex = index - 1;
        resetSelections();
        break;
      case 'Enter':
        int cursorY = widget.cursorManager.lineIndex;
        int cursorX = widget.cursorManager.runeIndex;
        List<Rune> runes = lineControllers[cursorY].getRunes(0, lineControllers[cursorY].getRunesLength());
        List<Rune> firstPart = runes.sublist(0, cursorX);
        List<Rune> secondPart = runes.sublist(cursorX, runes.length);
        var strBuffer = StringBuffer();
        for (var rune in firstPart) {
          if (rune.isVar) {
            strBuffer.write(rune.varKey);
          } else {
            strBuffer.write(rune.ch);
          }
        }
        document.lines[cursorY] = strBuffer.toString();
        strBuffer.clear();
        for (var rune in secondPart) {
          if (rune.isVar) {
            strBuffer.write(rune.varKey);
          } else {
            strBuffer.write(rune.ch);
          }
        }
        document.lines.insert(cursorY + 1, strBuffer.toString());
        setState(() {
          
        });
        break;
      default:
        // int keyId = event.logicalKey.keyId;
        if (event.character != null) {
          int cursorX = widget.cursorManager.runeIndex;
          int cursorY = widget.cursorManager.lineIndex;
          print('line: $cursorY col: $cursorX');
          lineControllers[cursorY].insertChar(cursorX, event.character);
          widget.cursorManager.runeIndex += 1;
        }
        break;
    }
  }

}