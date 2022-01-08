import 'package:GoNawazGo/service/Classifier.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class QuantClassifier extends Classifier {
  String tfLiteFile;
  String labelFile;

  QuantClassifier(
      {int numThreads: 1,
      this.tfLiteFile: 'model/model.tflite',
      this.labelFile: 'assets/model/dict.txt'})
      : super(labelFile, numThreads: numThreads);

  @override
  String get modelName => tfLiteFile;

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(0, 1);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 255);
}
