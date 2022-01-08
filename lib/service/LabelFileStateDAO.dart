import 'package:GoNawazGo/model/Avatar.dart';
import 'package:GoNawazGo/model/LabelFileState.dart';
import 'package:GoNawazGo/service/SettingsManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LabelFileStateDAO {
  static const String LABEL_STATE_TBL = 'LabelFileState';
  static const CONFIDENCE_THRESHOLD = 0.30;
  static int SCAN_LIMIT = 50;
  static Database database;

  LabelFileStateDAO();

  Future<List<LabelFileState>> filterImages(
      List<String> imagePaths, Avatar avatar) async {
    SharedPreferences prefs = await SettingsManager().getSharedPrefs();
    double threshold = prefs.getDouble(avatar.label);
    SCAN_LIMIT = prefs.getInt(SettingsManager.SEARCH_COUNT);
    List<LabelFileState> labelFileStates = [];
    int counter = 0;
    for (String path in imagePaths) {
      List<LabelFileState> statesFromDB =
          await getLabelFileStates(avatar.label, path);
      if (statesFromDB.isEmpty) {
        counter++;
        labelFileStates.add(LabelFileState(
            label: avatar.label,
            filePath: path,
            scanned: 0,
            wrongMatch: 0,
            confidence: 0.0,
            comment: '',
            fileSize: 0,
            left: 0.0,
            top: 0.0,
            right: 0.0,
            bottom: 0.0));
      } else if (statesFromDB[0].confidence.compareTo(threshold) >= 0 &&
          statesFromDB[0].wrongMatch == 0) {
        // cache
        print('Using cached ${statesFromDB[0]}');
        labelFileStates.add(statesFromDB[0]);
      } else if (statesFromDB[0].confidence.compareTo(threshold) < 0) {
        // print('Skipping ${statesFromDB[0].filePath}');
        print('Skipping ${statesFromDB[0]}');
      }

      if (counter == SCAN_LIMIT) {
        break;
      }
    }

    return labelFileStates;
  }

  Future<List<LabelFileState>> getAllPreMatchedImages(Avatar avatar) async {
    SharedPreferences prefs = await SettingsManager().getSharedPrefs();
    double threshold = prefs.getDouble(avatar.label);

    List<LabelFileState> labelFileStates = [];
    List<LabelFileState> statesFromDB = await getAllLabelFileStates(avatar.label);

    // cache
    statesFromDB.forEach((state) {
      if (state.confidence.compareTo(threshold) >= 0 && state.wrongMatch == 0) {
        print('Found cached match $state');
        labelFileStates.add(state);
      }
    });

    return labelFileStates;
  }

  Future<void> insertLabelFileState(LabelFileState state) async {
    // Get a reference to the database.
    final Database db = await getDatabase();

    await db.insert(
      LABEL_STATE_TBL,
      state.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LabelFileState>> getAllLabelFileStates(
      String label) async {
    // Get a reference to the database.
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      LABEL_STATE_TBL,
      where: "label = ?",
      whereArgs: [label],
    );

    return List.generate(maps.length, (i) {
      return LabelFileState(
        label: maps[i]['label'],
        filePath: maps[i]['filePath'],
        scanned: maps[i]['scanned'],
        confidence: maps[i]['confidence'],
        wrongMatch: maps[i]['wrongMatch'],
        comment: maps[i]['comment'],
        fileSize: maps[i]['fileSize'],
        left: maps[i]['left'],
        top: maps[i]['top'],
        right: maps[i]['right'],
        bottom: maps[i]['bottom'],
      );
    });
  }

  Future<List<LabelFileState>> getLabelFileStates(
      String label, String filePath) async {
    // Get a reference to the database.
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
      LABEL_STATE_TBL,
      where: "label = ? AND filePath = ?",
      whereArgs: [label, filePath],
    );

    return List.generate(maps.length, (i) {
      return LabelFileState(
        label: maps[i]['label'],
        filePath: maps[i]['filePath'],
        scanned: maps[i]['scanned'],
        confidence: maps[i]['confidence'],
        wrongMatch: maps[i]['wrongMatch'],
        comment: maps[i]['comment'],
        fileSize: maps[i]['fileSize'],
        left: maps[i]['left'],
        top: maps[i]['top'],
        right: maps[i]['right'],
        bottom: maps[i]['bottom'],
      );
    });
  }

  Future<void> updateLabelFileState(LabelFileState state) async {
    // Get a reference to the database.
    final db = await getDatabase();

    int res = await db.update(
      LABEL_STATE_TBL,
      state.toMap(),
      where: "filePath = ? AND label = ?",
      whereArgs: [state.filePath, state.label],
    );

    print('${state.filePath} is marked as wrong match.');
  }

  Future<void> deleteLabelFileState(String path) async {
    // Get a reference to the database.
    final db = await getDatabase();

    await db.delete(
      LABEL_STATE_TBL,
      where: "filePath = ?",
      whereArgs: [path],
    );
  }

  Future<Database> getDatabase() async {
    if (database == null) {
      database = await initDatabase();
    }

    return database;
  }

  Future<Database> initDatabase() async {
    return openDatabase(join(await getDatabasesPath(), 'flapp.db'),
        onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE LabelFileState(label TEXT, filePath TEXT, confidence REAL, scanned INTEGER, wrongMatch INTEGER, comment TEXT, fileSize INTEGER, left REAL, top REAL, right REAL, bottom REAL)",
      );
    }, version: 1);
  }
}
