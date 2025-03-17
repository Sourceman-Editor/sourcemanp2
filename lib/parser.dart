/*
  Parse raw text file line by line, and convert to a data structure that 
  can be easily highlighted by editor.
  The rule for a variable is as following:
    1. Variables should be saved as raw file
    2. Variables are saved in this format: 
      starting with a special character, followed by a few random strings, then ending with the same special character.
      In this format, we should be able to easily parse a parameter from a raw text.
 */
import 'package:sourcemanv2/datatype.dart';

const int magicVarLength = 10;
final int magicCharacter = "\$".codeUnitAt(0);

enum ParseMode {text, variable}

/*
  
 */
List<Rune> parseline(String line) {
  List<Rune> parsed = [];
  ParseMode mode = ParseMode.text;
  List<int> varCodes = [];
  line.runes.forEach((r) {
    if (mode == ParseMode.text) {
      if (r == magicCharacter) {
        mode = ParseMode.variable;
        return;
      }
      String ch = String.fromCharCode(r);
      Rune rune = Rune(isVar: false, ch: ch);
      parsed.add(rune);
    } else if (mode == ParseMode.variable) {
      bool discardFlag = false;
      if (varCodes.length >= magicVarLength) {
        if (r != magicCharacter) {
          discardFlag = true;
        }
      } else {
        varCodes.add(r);
        return;
      }
      if (discardFlag) {
        String ch = String.fromCharCode(magicCharacter);
        Rune firstRune = Rune(isVar: false, ch: ch);
        parsed.add(firstRune);
        for (int v in varCodes) {
          ch = String.fromCharCode(v);
          Rune rune = Rune(isVar: false, ch: ch);
          parsed.add(rune);
        }
        ch = String.fromCharCode(r);
        Rune rune = Rune(isVar: false, ch: ch);
        parsed.add(rune);
      } else {
        print("found var");
        String key = String.fromCharCodes(varCodes);
        Rune rune = Rune(isVar: true, varKey: key);
        parsed.add(rune);
      }
      mode = ParseMode.text;
    }
  });
  return parsed;
}