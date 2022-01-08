import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class CategoryDetail extends Category {
  Face _face;
  CategoryDetail(String label, double score, this._face) : super(label, score);

  Face get face => _face;

}