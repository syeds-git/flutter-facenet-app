import 'package:GoNawazGo/model/Avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {

  static const String IS_FIRST = 'IS_FIRST';
  static const String PICKED_PATH = 'PICKED_PATH';
  static const String SEARCH_COUNT = 'SEARCH_COUNT';
  static const String SEARCH_FROM_LATEST = 'SEARCH_FROM_LATEST';

  static SharedPreferences prefs;

  Future<SharedPreferences> getSharedPrefs() async {
    if (prefs == null) {
      await initDefaults();
    }

    return prefs;
  }

  initDefaults([bool forceInit = false]) async {
    bool init = false;
    prefs = await SharedPreferences.getInstance();
    String isFirst = prefs.getString(IS_FIRST);
    if (isFirst == null || isFirst.isEmpty) {
      print('Initializing settings');
      prefs.setString(IS_FIRST, 'INSTALLED');
      init = true;
    } else if (forceInit) {
      init = true;
      print('Forced initializing');
    } else {
      print('Not initializing');
    }

    if (init) {
      prefs.setString(PICKED_PATH, '');
      prefs.setInt(SEARCH_COUNT, 50);
      prefs.setBool(SEARCH_FROM_LATEST, true);
      Avatar.fetchAll().forEach((person) {
        prefs.setDouble('${person.label}', person.confidence);
      });
    }
  }
}