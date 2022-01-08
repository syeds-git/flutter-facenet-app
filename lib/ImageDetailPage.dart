import 'dart:io';

import 'package:GoNawazGo/model/Avatar.dart';
import 'package:GoNawazGo/model/LabelFileState.dart';
import 'package:GoNawazGo/service/FacePainter.dart';
import 'package:GoNawazGo/widget/DrawerWidget.dart';
import 'package:GoNawazGo/widget/FABBottomAppBar.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageDetailPage extends StatefulWidget {
  ImageDetailPage(this.imageState, this.prefs);

  LabelFileState imageState;
  SharedPreferences prefs;

  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  ui.Image uiImage;
  String _lastSelected = 'TAB: 0';

  @override
  void initState() {
    super.initState();
    File(this.widget.imageState.filePath).readAsBytes().then((file) => {
          decodeImageFromList(file).then((value) => setState(() {
                uiImage = value;
              }))
        });
  }

  String getImageFileName(String imagePath) {
    return imagePath.substring(imagePath.lastIndexOf('/') + 1, imagePath.lastIndexOf('.'));
  }

  void _selectedTab(int index) async {
    setState(() {
      _lastSelected = 'TAB: $index';
      if (index == 0) {
        Navigator.pop(context);
      } else if (index == 1) {
        _drawerKey.currentState.openDrawer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String fullName = Avatar.findByLabel(this.widget.imageState.label).fullName;
    return Scaffold(
      key: _drawerKey,
      drawer: DrawerWidget('Go Nawaz Go', widget.prefs),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Is this ${fullName}?'),
      ),
      body: (uiImage == null)
          ? Center(child: Text('No image selected'))
          : Column(
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: uiImage.width.toDouble(),
                      height: uiImage.height.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(uiImage, widget.imageState.rect),
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 20,
                  thickness: 5,
                  indent: 10,
                  endIndent: 10,
                ),
                Expanded(
                    flex: 3,
                    child: ListView(
                        children: <Widget>[
                          Card(
                            child: ListTile(
                              title: Text('File path'),
                              subtitle: Text(widget.imageState.filePath),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              title: Text('Match confidence'),
                              subtitle: Text(widget.imageState.confidence.toString()),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              title: Text('File size (kb)'),
                              subtitle: Text((widget.imageState.fileSize/1000).toString()),
                            ),
                          ),
                        ])),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Share.shareFiles([widget.imageState.filePath], text: 'This image has ${widget.imageState.label} with a confidence of ${widget.imageState.confidence}');
        },
        tooltip: 'Share',
        child: InkWell(child: Icon(Icons.share)),
      ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        color: Colors.green,
        selectedColor: Colors.green,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: Icons.west, text: ''),
          FABBottomAppBarItem(iconData: Icons.view_sidebar, text: ''),
          // FABBottomAppBarItem(iconData: Icons.share, text: ''),
          // FABBottomAppBarItem(iconData: Icons.info, text: ''),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
