import '../datatype.dart';

class EnvVarManager {
  Map<String, List<EnvVar>> cache = {};

  void parseJsonEnvVars(dynamic envVars, String profileKey, String documentKey) {

    for (var entry in envVars) {
      String key = entry["key"];
      String value = entry["value"];
      EnvVar tmp = EnvVar(
        documentKey: documentKey,
        profileKey: profileKey,
        key: key,
        value: value,
      );
      if (cache.containsKey(profileKey)) {
        cache[profileKey]?.add(tmp);
      } else {
        cache[profileKey] = [tmp];
      }
    }
  }

  List<EnvVar> findEnvVarsByProfileKey(String profileKey) {
    return cache[profileKey]?? [];
  }

  EnvVar? findVarByKey(String profileKey, String key) {
    List<EnvVar> list = cache[profileKey]?? [];
    for (var e in list) {
      if (e.key == key) {
        return e;
      }
    }
  }

}