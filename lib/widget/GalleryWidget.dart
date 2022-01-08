import 'dart:io';
import 'package:GoNawazGo/model/LabelFileState.dart';
import 'package:flutter/material.dart';
import 'package:GoNawazGo/model/Avatar.dart';

typedef ImageDeleteCallback = void Function(String imagePath);
typedef ImageTapCallback = void Function(LabelFileState imageState);

class GalleryWidget extends StatelessWidget {
  final ImageDeleteCallback onImageDelete;
  final ImageTapCallback onImageTap;
  final List<LabelFileState> imagePaths;
  final Avatar selectedPerson;

  GalleryWidget(this.imagePaths, this.selectedPerson, this.onImageDelete, this.onImageTap);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: getImageTiles(imagePaths),
    );
  }

  String getImageFileName(String imagePath) {
    return imagePath.substring(imagePath.lastIndexOf('/') + 1, imagePath.lastIndexOf('.'));
  }

  List<Widget> getImageTiles(List<LabelFileState> imageStates) {
    return imageStates
        .map((imageState) => GridTile(
              // header: GestureDetector(
              //   onTap: () {
              //     Share.shareFiles([imageState.filePath], text: '${getImageFileName(imageState.filePath)}');
              //   },
              //   child: GridTileBar(
              //     backgroundColor: Colors.black45,
              //     subtitle: _GridTitleText('${getImageFileName(imageState.filePath)}'),
              //     trailing: Icon(
              //       Icons.share,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              footer: GestureDetector(
                onTap: () {
                  this.onImageDelete(imageState.filePath);
                },
                child: GridTileBar(
                  backgroundColor: Colors.black45,
                  // title: _GridTitleText('Wrong picture?'),
                  subtitle: _GridTitleText('Wrong match?'),
                  trailing: Icon(
                    Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
              child: GestureDetector(
                  child: Image.file(File(imageState.filePath), fit: BoxFit.cover),
                onTap: () {
                    this.onImageTap(imageState);
                },
              ),
            ))
        .toList();
  }
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text),
    );
  }
}
