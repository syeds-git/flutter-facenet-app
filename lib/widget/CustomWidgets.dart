import 'dart:io';

import 'package:GoNawazGo/model/Avatar.dart';
import 'package:GoNawazGo/model/LabelFileState.dart';
import 'package:GoNawazGo/widget/FABBottomAppBar.dart';
import 'package:flutter/material.dart';

class CustomWidgets {
  static AppBar getAppBar(String title, bool isLoading, GlobalKey<ScaffoldState> _drawerKey) {
    return AppBar(
      title: Text(title),
      leading: Padding(
        padding: EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () {},
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/ns.png'),
            backgroundColor: Colors.green.shade800,
            // child: Text('NS'),
          ),
        ),
      ),
      actions: <Widget>[
        Visibility(
          visible: !isLoading,
          child: IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Display settings page',
            onPressed: () {
              _drawerKey.currentState.openDrawer();
            },
          ),
        ),
      ],
    );
  }

  static FloatingActionButton buildFloatingActionButton(bool isLoading, bool hasImages, int count, Function func, BuildContext context) {
    if (isLoading) {
      return FloatingActionButton(
        tooltip: 'Loading',
        child: Text(
          count.toString(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        // child: InkWell(child: Icon(Icons.watch_later_outlined)),
      );
    } else if (hasImages) {
      return FloatingActionButton(
        onPressed: func,
        tooltip: 'Scan',
        child: InkWell(child: Icon(Icons.search)),
      );
    } else {
      return FloatingActionButton(
        tooltip: 'Scan',
        child: InkWell(child: Icon(Icons.search)),
      );
    }
  }

  static List<FABBottomAppBarItem> getFABItems() {
    return [
      FABBottomAppBarItem(iconData: Icons.folder, text: ''),
      // FABBottomAppBarItem(iconData: Icons.attach_money_sharp, text: ''),
      // FABBottomAppBarItem(iconData: Icons.share, text: ''),
      FABBottomAppBarItem(iconData: Icons.delete, text: ''),
    ];
  }

  static Expanded getInfoText(BuildContext context,
      List<LabelFileState> imagePaths, bool isLoading, String scanPath, Avatar selectedAvatar) {
    return imagePaths.isNotEmpty && !isLoading
        ? Expanded(
            child: Center(
              child: Text(
                'Search results for ${selectedAvatar.firstName} ${selectedAvatar.lastName}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          )
        : Expanded(
            child: Column(
              children: [
                Center(
                  child: isLoading
                      ? Text(
                    'Scanning',
                    style: Theme.of(context).textTheme.headline4,
                  )
                      : null,
                ),
                Center(
                  child: isLoading
                      ? Text(
                    '${scanPath}',
                    style: Theme.of(context).textTheme.headline6,
                  )
                      : null,
                ),
              ],
            ),
          );
  }
}
