import 'dart:ui';

class LabelFileState {
  String label;
  String filePath;
  double confidence;
  int scanned;
  int wrongMatch;
  String comment;
  int fileSize;
  double left;
  double top;
  double right;
  double bottom;

  LabelFileState({this.label, this.filePath, this.scanned, this.confidence, this.wrongMatch, this.comment, this.fileSize, this.left, this.top, this.right, this.bottom});

  Rect get rect => Rect.fromLTRB(left, top, right, bottom);

  @override
  String toString() {
    return "<LabelFileState \"" +
        label +
        "\" (confidence=" +
        confidence.toStringAsFixed(3) +
        ') $filePath >';
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'filePath': filePath,
      'scanned': scanned,
      'confidence': confidence,
      'wrongMatch': wrongMatch,
      'comment': comment,
      'fileSize': fileSize,
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }
}