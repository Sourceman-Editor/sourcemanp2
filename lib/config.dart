import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Configuration {
  // colors, black and white
  // static TextStyle defaultTextStyle = const TextStyle(fontFamily: 'FiraCode', fontSize: 18, color: Color(0xff272822));
  // static const Color showCursorColor = Color.fromARGB(255, 0, 0, 0);
  // static const Color highlightColor =Color.fromARGB(255, 159, 208, 241);
  // static Border cursorBorder = const Border(left: BorderSide(width: Configuration.cursorWidth, color: Color.fromARGB(153, 61, 58, 58),));
  static const Color hideCursorColor = Color.fromARGB(255, 0, 0, 0);
  static BoxShadow highlightBoxShadow = const BoxShadow(color: Configuration.highlightColor, offset: Offset(1, 0));
  static Border defaultBorder = const Border(left: BorderSide(width: Configuration.cursorWidth, color: Color.fromARGB(0, 255, 255, 255),));

  // colors, like vscode
  static const Color backgroundColor = Color.fromARGB(255, 31, 30, 30);
  static TextStyle defaultTextStyle = const TextStyle(fontFamily: 'FiraCode', fontSize: 18, color: Color.fromARGB(255, 0, 0, 0));
  static const Color showCursorColor = Color.fromARGB(255, 0, 0, 0);
  static const Color highlightColor =Color.fromARGB(45, 133, 187, 218);
  static Border cursorBorder = const Border(left: BorderSide(width: Configuration.cursorWidth, color: Color.fromARGB(153, 0, 0, 0),));
  static Border fileExplorerFolderBorder = const Border(left: BorderSide(width: 0.5, color: Color.fromARGB(153, 236, 236, 233),));
  static Border defaultVarBorder = const Border(
    left: BorderSide(width: 1, color: Color.fromARGB(255, 219, 219, 214),),
    right: BorderSide(width: 1, color: Color.fromARGB(255, 219, 219, 214),),
    top: BorderSide(width: 0.3, color: Color.fromARGB(255, 219, 219, 214),),
    bottom: BorderSide(width: 1, color: Color.fromARGB(255, 219, 219, 214),),
  );
  static const Color defaultVarColor = Color.fromARGB(255, 214, 205, 205);
  static const Color themeColor = Color.fromARGB(255, 61, 60, 60);

  // sizes
  static const double cursorWidth = 2;
  static const double cursorHeight = 22;
  static const double height = 20;
  static const double clickOffset = -4;

}