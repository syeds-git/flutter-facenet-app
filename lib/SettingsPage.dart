import 'package:GoNawazGo/model/Avatar.dart';
import 'package:GoNawazGo/service/SettingsManager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage(this.appTitle, this.prefs) {}

  String appTitle;
  SharedPreferences prefs;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences prefs;

  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade800,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      prefs = widget.prefs;
    });
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }

  List<Widget> getAvatarSettingTiles() {
    return Avatar.fetchAll()
        .map((avatar) => Column(
        children: <Widget>[
          ListTile(
            title: Text(avatar.fullName),
            trailing: Text(prefs.getDouble(avatar.label).toString()),
            subtitle: Slider(
              value: prefs.getDouble(avatar.label),
              min: 0,
              max: 1,
              divisions: 20,
              label: prefs.getDouble(avatar.label).toString(),
              onChanged: (double value) {
                setState(() {
                  prefs.setDouble(avatar.label, value);
                });
              },
            ),
          ),
          _buildDivider(),
        ]
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Search",
              style: headerStyle,
            ),
            const SizedBox(height: 10.0),
            Card(
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 0,
              ),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    activeColor: Colors.green,
                    value: prefs.getBool(SettingsManager.SEARCH_FROM_LATEST),
                    title: Text("Start search from latest images"),
                    onChanged: (val) {
                      setState(() {
                        prefs.setBool(SettingsManager.SEARCH_FROM_LATEST, val);
                      });
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    title: Text('Number of images to scan at a time'),
                    subtitle: Text(
                        'Selecting larger number will take longer to bring back results'),
                    trailing: DropdownButton<int>(
                      value: prefs.getInt(SettingsManager.SEARCH_COUNT),
                      // icon: Icon(Icons.download_done_sharp),
                      iconSize: 0,
                      elevation: 16,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20.0,
                      ),
                      underline: Container(
                        height: 0,
                        color: Colors.greenAccent,
                      ),
                      onChanged: (int newValue) {
                        setState(() {
                          prefs.setInt(SettingsManager.SEARCH_COUNT, newValue);
                        });
                      },
                      items: <int>[25, 50, 100, 500, 999]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              "Advanced Settings",
              style: headerStyle,
            ),
            const SizedBox(height: 10.0),
            Text(
              "These settings determine how strictly AI face matching is performed for a given person.",
            ),
            const SizedBox(height: 10.0),
            Text(
              "Use a higher number for more accurate results but that may also exclude some valid matches.",
            ),
            const SizedBox(height: 10.0),
            Card(
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 0,
              ),
              child: Column(
                children: <Widget>[
                  ...getAvatarSettingTiles(),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              "RESET",
              style: headerStyle,
            ),
            Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0,
                ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('This will reset all settings'),
                      leading: Icon(Icons.warning_amber_rounded),
                      trailing: Ink(
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.autorenew),
                          onPressed: () async {
                            var settings = SettingsManager();
                            await settings.initDefaults(true);
                            var sp = await settings.getSharedPrefs();
                            setState(() {
                              prefs = sp;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
