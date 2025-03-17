class CursorManager {
  bool dragging = false;
  int lineIndex = 0;
  int runeIndex = 0;
  int selectStart = 0;
  int selectStartLine = 0;
  int selectEnd = 0;
  int selectEndLine = 0;

  void setSelectStart() {
    selectStart = runeIndex;
    selectStartLine = lineIndex;
    selectEnd = selectStart;
    selectEndLine = selectStartLine;
  }

  void setSelectEnd() {
    selectEnd = runeIndex;
    selectEndLine = lineIndex;
  }

  void debugPrint() {
    print("cursor, start: $selectStart, $selectStartLine; end: $selectEnd, $selectEndLine");
  }
}