import 'dart:math';

import 'package:GoNawazGo/service/Classifier.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FloatClassifier extends Classifier {
  String tfLiteFile;
  String labelFile;

  FloatClassifier(
      {int numThreads,
      this.tfLiteFile: 'model/model.tflite',
      this.labelFile: 'assets/model/dict.txt',
      bool faceNet: false})
      : super(labelFile, numThreads: numThreads, faceNet: faceNet);

  @override
  String get modelName => this.tfLiteFile;

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);
}
