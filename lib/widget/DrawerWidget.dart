import 'package:GoNawazGo/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatelessWidget {
  String title;
  SharedPreferences prefs;
  DrawerWidget(this.title, this.prefs) {}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createDrawerTitleItem(context, title),
          Divider(),
          _createDrawerItem(
              icon: Icons.settings,
              text: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (ctxt) => new SettingsPage(title, prefs)));
              }),
          Divider(),
          _createDrawerItem(
            icon: Icons.info_outlined,
            text: 'About',
          ),
          ListTile(
            title: Text('0.4.2+4'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _createTitle(String title) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Stack(children: <Widget>[
        Positioned(
            top: 10,
            left: 16.0,
            child: Text(title,
                style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _createHeader(String title) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill, image: AssetImage('assets/images/'))),
      child: Stack(children: <Widget>[
        Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Text(title,
                style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _createDrawerTitleItem(BuildContext context, String text) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 25),
            child: Text(title,
                style: TextStyle(
                    // color: Colors.green.shade700,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500)),
          )
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
