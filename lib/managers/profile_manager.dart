import '../datatype.dart';
import 'env_var_manager.dart';

class ProfileManager {
  Map<String, List<Profile>> cache = {}; 

  /*
    First one returned needs to be default profile
   */
  List<Profile> findProfilesByDocumentKey(String documentKey) {
    return cache[documentKey]??[];
  }

  Profile? findProfileByKey(String documentKey, String profileKey) {
    for (Profile p in cache[documentKey]?? []) {
      if (p.key == profileKey) {
        return p;
      }
    }
    return null;
  }

  /*
    json values
  */
  List<Profile> parseJsonProfiles(dynamic profiles, String documentKey, EnvVarManager envVarManager) {
    List<Profile> parsed = [];
    for (var entry in profiles) {
      String key = entry["key"];
      String name = entry["name"];
      String description = entry["description"];
      double createdTime = entry["createdTime"].toDouble();
      Profile tmp = Profile(
        key: key,
        name: name,
        description: description,
        createdTime: createdTime, 
      );
      parsed.add(tmp);
      var envVars = entry["envs"];
      envVarManager.parseJsonEnvVars(envVars, key, documentKey);
    }
    cache[documentKey] = parsed;
    return parsed;
  }

}