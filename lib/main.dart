import 'dart:io';

import 'package:GoNawazGo/service/SettingsManager.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:GoNawazGo/MainPage.dart';
import 'package:GoNawazGo/service/LabelFileStateDAO.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LabelFileStateDAO labelFileStateDAO = LabelFileStateDAO();
  SettingsManager settingsManager = SettingsManager();
  Admob.initialize(testDeviceIds: ['<TEST_DEVICE_ID>']);

  await labelFileStateDAO.initDatabase();
  await settingsManager.initDefaults();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp(
      labelFileStateDAO: labelFileStateDAO,
      settingsManager: settingsManager,
    ));
  });
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final LabelFileStateDAO labelFileStateDAO;
  final SettingsManager settingsManager;

  const MyApp({Key key, this.labelFileStateDAO, this.settingsManager})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go Nawaz Go',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(
          title: 'Go Nawaz Go',
          labelFileStateDAO: this.labelFileStateDAO,
          settingsManager: this.settingsManager),
    );
  }
}
