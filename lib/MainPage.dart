import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:GoNawazGo/ImageDetailPage.dart';
import 'package:GoNawazGo/service/AdManager.dart';
import 'package:GoNawazGo/service/SettingsManager.dart';
import 'package:GoNawazGo/widget/AvatarWidget.dart';
import 'package:GoNawazGo/widget/CustomWidgets.dart';
import 'package:GoNawazGo/widget/DrawerWidget.dart';
import 'package:GoNawazGo/widget/FABBottomAppBar.dart';
import 'package:GoNawazGo/widget/GalleryWidget.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:GoNawazGo/model/Avatar.dart';
import 'package:GoNawazGo/model/LabelFileState.dart';
import 'package:GoNawazGo/service/LabelFileStateDAO.dart';
import 'package:GoNawazGo/service/ModelManager.dart';
import 'package:GoNawazGo/service/Utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title, this.labelFileStateDAO, this.settingsManager}) : super(key: key);

  final String title;
  final LabelFileStateDAO labelFileStateDAO;
  final SettingsManager settingsManager;

  @override
  _MainPageState createState() => _MainPageState(labelFileStateDAO);
}

class _MainPageState extends State<MainPage> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final LabelFileStateDAO labelFileStateDAO;
  ModelManager modelManager;
  bool isLoading = true;
  Avatar selectedAvatar;
  List<LabelFileState> imagePaths = [];
  var progress = 0.0;
  var displayCount = 0;
  SharedPreferences prefs;
  Directory rootPath;
  Directory watsappImages;

  @override
  void initState() {
    super.initState();

    this.widget.settingsManager.getSharedPrefs().then((value) {
      prefs = value;
    });

    getExternalStorageDirectory().then((value) {
      print('Root Path is ${value.path}');
      rootPath = value.parent.parent.parent.parent;
      setState(() {
        if (prefs.getString(SettingsManager.PICKED_PATH) == null || prefs.getString(SettingsManager.PICKED_PATH).isEmpty) {
          prefs.setString(SettingsManager.PICKED_PATH, '${rootPath.path}/Whatsapp/Media/WhatsApp Images');
          print('Setting default path to ${'${rootPath.path}/Whatsapp/Media/WhatsApp Images'}');
        }
      });
    });

    setState(() {
      isLoading = true;
    });

    modelManager = ModelManager();
    modelManager.initClassifier();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  processSelectedAvatar(Avatar avatar) async {
    List<LabelFileState> preMatched = await labelFileStateDAO.getAllPreMatchedImages(avatar);
    if (preMatched.isEmpty) {
      setState(() {
        this.progress = 0;
        this.isLoading = true;
        LabelFileStateDAO.SCAN_LIMIT = prefs.getInt(SettingsManager.SEARCH_COUNT);
        this.displayCount = LabelFileStateDAO.SCAN_LIMIT;
      });

      await scanAvatar(avatar);
    } else {
      setState(() {
        this.imagePaths = preMatched;
        this.isLoading = false;
      });
    }
  }

  scanSelectedAvatar() async {
    setState(() {
      this.progress = 0;
      this.isLoading = true;
      LabelFileStateDAO.SCAN_LIMIT = prefs.getInt(SettingsManager.SEARCH_COUNT);
      this.displayCount = LabelFileStateDAO.SCAN_LIMIT;
    });

    await scanAvatar(this.selectedAvatar);
  }

  scanAvatar(Avatar avatar) async {
    List<String> images = [];
    List<LabelFileState> filteredImages = [];
    if (await Permission.storage.request().isGranted) {
      if (Platform.isAndroid) {
        Directory appDir = await getExternalStorageDirectory();

        // Following gets all whatsapp images on android
        // appDir.parent.parent.parent.parent.list().forEach((element) { print(element);});

        String dirPath = prefs.getString(SettingsManager.PICKED_PATH);
        if (dirPath != null && dirPath.isNotEmpty) {
          watsappImages = Directory(dirPath);
        } else {
          watsappImages = Directory(
              '${appDir.parent.parent.parent.parent.path}/Whatsapp/Media/WhatsApp Images');
        }

        var exists = await watsappImages.exists();
        if (exists) {
          bool reversed = prefs.getBool(SettingsManager.SEARCH_FROM_LATEST);
          var imagesList = await watsappImages.list().toList();
          if (reversed) {
            imagesList = imagesList.reversed.toList();
          }

          imagesList.forEach((element) {
            var imgPath = element.path;
            var imgName = Utils.getFileNameFromPath(element.path);
            images.add(imgPath);
          });

          List<LabelFileState> filteredFiles =
          await labelFileStateDAO.filterImages(images, avatar);

          int count = 0;
          for (LabelFileState imageFileState in filteredFiles) {
            if (imageFileState.scanned == 0) {
              try {
                final imageFile = File(imageFileState.filePath);
                imageFileState.fileSize = imageFile.lengthSync();
                var recs = await modelManager.processImageWithClassifier(
                    imageFile, avatar);
                setState(() {
                  count++;
                  displayCount--;
                  progress = count / LabelFileStateDAO.SCAN_LIMIT;
                });

                // print('$count ${imageFileState.filePath}');
                // for (var r in recs) {
                //   var rec = Map<String, dynamic>.from(r);
                //   if (rec['label'] == avatar.label) {
                //     var matchConfidence = rec['confidence'];
                //     imageFileState.confidence = matchConfidence;
                //     if (matchConfidence > 0.90) {
                //       filteredImages.add(imageFileState.filePath);
                //       break;
                //     }
                //   }
                // }

                var maxConfidence = -1.0;
                for (var category in recs) {
                  var matchConfidence = category.score;
                  if (category.label == avatar.label) {
                    imageFileState.confidence = matchConfidence;
                    imageFileState.left = category.face.boundingBox.left;
                    imageFileState.top = category.face.boundingBox.top;
                    imageFileState.right = category.face.boundingBox.right;
                    imageFileState.bottom = category.face.boundingBox.bottom;
                    if (avatar.confidence.compareTo(matchConfidence) <= 0) {
                      filteredImages.add(imageFileState);
                      break;
                    } else {
                      maxConfidence = max(maxConfidence, matchConfidence);
                    }
                  } else {
                    var imageForOtherPerson = LabelFileState(
                        label: category.label,
                        filePath: imageFileState.filePath,
                        scanned: 1,
                        wrongMatch: 0,
                        confidence: matchConfidence,
                        comment: '');
                    await labelFileStateDAO
                        .insertLabelFileState(imageForOtherPerson);
                    print(
                        'Saved result for ${category.label} as $imageForOtherPerson');
                  }
                }

                print('${imageFileState.filePath} contains: $recs');
                imageFileState.scanned = 1;
                imageFileState.wrongMatch = 0;
                imageFileState.confidence =
                    max(imageFileState.confidence, maxConfidence);
                await labelFileStateDAO.insertLabelFileState(imageFileState);
              } catch (ex) {
                print('Exception while processing images ${ex}');
              }
            } else {
              print('Using cached result for ${imageFileState.filePath}');
              filteredImages.add(imageFileState);
            }
          }

          setState(() {
            this.imagePaths = filteredImages;
            this.isLoading = false;
            if (this.imagePaths.isEmpty) {
              displayNotFoundDialog(avatar);
            }
          });
        } else {
          setState(() {
            this.isLoading = false;
          });
        }
      } else {
        // iOS-specific code
        print("IOS IOS IOS");
      }
    } else {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  recordWrongMatch(LabelFileState state) async {
    await labelFileStateDAO.updateLabelFileState(state);
  }

  _getImageAndDetectFaces(Avatar avatar) async {
    if (await Permission.storage.request().isGranted) {
      if (Platform.isAndroid) {
        await processSelectedAvatar(avatar);

        // TODO remove sample code
        // Directory result = await getExternalStorageDirectory();
        // print(result.absolute.path);
        //
        // List<Directory> r = await getExternalStorageDirectories();
        // r.forEach((element) {
        //   print(element);
        // });

        // Following uses ExtStorage plugin to get directories
        // var path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_PICTURES);
        // print(path);
        // Directory pics = Directory(path);
        // pics.list().forEach((element) { print(element);});
      } else if (Platform.isIOS) {
        // iOS-specific code
        print("IOS IOS IOS");
      }
    }

    setState(() {
      isLoading = true;
    });
  }

  _MainPageState(this.labelFileStateDAO);

  void confirmDeleteMatchedImages() {
    if (!this.isLoading &&
        this.selectedAvatar != null &&
        this.imagePaths.length > 0) {
      this.confirmDeleteDialog(this.selectedAvatar);
    }
  }

  void deleteMatchedImages() {
    this.imagePaths.forEach((imageState) {
      try {
        File(imageState.filePath).deleteSync();
        print('Deleted ${imageState.filePath}');
      } catch (ex) {
        print('Failed to delete ${imageState.filePath}');
        print(ex);
      }
    });

    setState(() {
      this.imagePaths.clear();
    });
  }

  String getText() {
    if (selectedAvatar != null && selectedAvatar.firstName != null) {
      return selectedAvatar.firstName;
    } else {
      return '';
    }
  }

  Future<void> confirmDeleteDialog(Avatar avatar) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${avatar.firstName} ${avatar.lastName}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to delete ${imagePaths.length} pictures of ${avatar.firstName} ${avatar.lastName} from your device?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes, of course!'),
              onPressed: () {
                this.deleteMatchedImages();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> displayNotFoundDialog(Avatar avatar) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${avatar.firstName} ${avatar.lastName}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Unable to find ${avatar.firstName} ${avatar.lastName} in this scan.'),
                Text(
                    'Try again to scan the next ${LabelFileStateDAO.SCAN_LIMIT} pictures.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> noMatchesToDelete(Avatar avatar) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${avatar.firstName} ${avatar.lastName}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'No matched images to delete.'),
                Text(
                    'Try searching in a different folder.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getAvatarWidget() {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 0.0),
      // color: Colors.black,
      height: 120.0,
      child: AvatarWidget(
        Avatar.fetchAll(),
        (Avatar av) {
          setState(() {
            selectedAvatar = av;
            processSelectedAvatar(av);
            // _getImageAndDetectFaces(av);
          });
        },
      ),
    );
  }

  Future<void> _pickDir(BuildContext context) async {
    String path = await FilesystemPicker.open(
      title: 'Select folder',
      context: context,
      rootDirectory: rootPath,
      fsType: FilesystemType.folder,
      pickText: 'Select folder for scanning',
      folderIconColor: Colors.teal,
      requestPermission: () async =>
          await Permission.storage.request().isGranted,
    );

    if (path != null || path.isNotEmpty) {
      prefs.setString(SettingsManager.PICKED_PATH, path);
      setState(() {
        print('Picked path is ${path}');
      });
    }
  }

  void _selectedTab(int index) async {
    setState(() {
      if (!isLoading) {
        if (index == 0) {
          _pickDir(context);
        } else if (index == 1) {
          if (selectedAvatar == null) {
            selectedAvatar = Avatar.fetchAll().first;
          }

          if (imagePaths.isNotEmpty) {
            confirmDeleteDialog(selectedAvatar);
          } else {
            noMatchesToDelete(selectedAvatar);
          }

          // showAboutDialog(
          //     context: context,
          //     applicationName: 'Go Nawaz Go',
          //     applicationLegalese: 'Some text here');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      appBar: CustomWidgets.getAppBar(widget.title, isLoading, _drawerKey),
      drawer: DrawerWidget(widget.title, prefs),
      // endDrawer: DrawerWidget(widget.title),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Following code displays ad on top while scanning
            isLoading
                ? AdmobBanner(
                    adUnitId: AdManager.bannerAdUnitId2,
                    adSize: AdmobBannerSize.BANNER,
                  )
                : getAvatarWidget(),
            // getAvatarWidget(),
            Row(
              children: [
                CustomWidgets.getInfoText(
                    context, imagePaths, isLoading, getScanPath(), selectedAvatar)
              ],
            ),
            Divider(
              height: 20,
              thickness: 5,
              indent: 10,
              endIndent: 10,
            ),
            // Expanded(
            //   child: AdmobBanner(
            //     adUnitId: AdManager.bannerAdUnitId,
            //     adSize: AdmobBannerSize.BANNER,
            //   ),
            // ),
            // Following code displays ad in middle while processing
            Visibility(
              visible: isLoading || this.imagePaths.isEmpty,
              child: Expanded(
                child: AdmobBanner(
                  adUnitId: AdManager.bannerAdUnitId,
                  adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                ),
              ),
            ),
            Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(value: progress),
                      )
                    : this.imagePaths.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                Text(
                                  'Select a person above to find in your device',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                prefs != null ?
                                Text(
                                  'Device location: ${getScanPath()}',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ) : Text(
                                  'Device location: Unknown',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ],
                            ),
                          )
                        : GalleryWidget(this.imagePaths, this.selectedAvatar,
                            (String imagePath) {
                            setState(() {
                              this.imagePaths.remove(imagePath);
                              recordWrongMatch(LabelFileState(
                                  label: selectedAvatar.label,
                                  filePath: imagePath,
                                  confidence: 0.05,
                                  scanned: 1,
                                  wrongMatch: 1,
                                  comment: 'Wrong match'));
                            });
                          }, (LabelFileState imageState) {
                            print('TAPPED');
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ImageDetailPage(imageState, prefs)));
                          })),
          ],
        ),
      ),
      floatingActionButton: CustomWidgets.buildFloatingActionButton(isLoading, this.imagePaths.length != 0, displayCount, scanSelectedAvatar, context),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        color: isLoading ? Colors.grey : Colors.green,
        selectedColor: isLoading ? Colors.grey : Colors.green,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: CustomWidgets.getFABItems(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  String getScanPath() => prefs == null ? '' : prefs.getString(SettingsManager.PICKED_PATH).replaceRange(0, rootPath.path.length, '');
}
