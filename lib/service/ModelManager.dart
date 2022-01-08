import 'dart:io';
import 'package:GoNawazGo/model/Avatar.dart';
import 'package:GoNawazGo/model/CategoryDetail.dart';
import 'package:GoNawazGo/service/Classifier.dart';
import 'package:GoNawazGo/service/FloatClassifier.dart';
import 'package:GoNawazGo/service/Utils.dart';
// import 'package:firebase_ml_custom/firebase_ml_custom.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ModelManager {
  // Classifier tfLiteC;
  Classifier faceNet;
  final Map<String, List<double>> baseFaces = Map();

  var logger = Logger();

  initClassifier() {
    // tfLiteA = FloatClassifier(
    //     tfLiteFile: 'model/efficientnet_lite4_spec_faces_clean_no_random_50_35.tflite',
    //     labelFile:
    //         'assets/model/efficientnet_lite4_spec_faces_clean_no_random_50_35.labels.txt');

    // tfLiteC = FloatClassifier();
    faceNet = FloatClassifier(tfLiteFile: 'model/<MODEL_NAME>.tflite', faceNet: true);
    initFaceNet();
  }

  void initFaceNet() async {
    for (Avatar avatar in Avatar.fetchAll()) {
      File avFile = await Utils.getImageFileFromAssets(avatar.trainImage, avatar.label + '-temp.png');
      img.Image imageInput = img.decodeImage(avFile.readAsBytesSync());
      List<double> embeddings = faceNet.predictFaceNet(imageInput);
      baseFaces[avatar.label] = embeddings;
      // print('Features for ${avatar.label}');
      // embeddings.forEach((element) {print(element);});
    }

    print('Finished init of facenet');
  }

  Future<List<CategoryDetail>> processImageWithClassifier(File imageFile, Avatar avatar) async {
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);
    File croppedFile;
    List<CategoryDetail> recs = [];
    print("Found ${faces.length} faces in ${imageFile.path}");
    int faceCount = 0;
    if (faces.length <= 5) {
      for (Face face in faces) {
        try {
          croppedFile = await FlutterNativeImage.cropImage(
              imageFile.path,
              face.boundingBox.left.toInt(),
              face.boundingBox.top.toInt(),
              face.boundingBox.width.toInt(),
              face.boundingBox.height.toInt());

          if (croppedFile != null) {
            print('Cropped File: $croppedFile for Face No: $faceCount');
            img.Image imageInput = img.decodeImage(croppedFile.readAsBytesSync());
            List<double> embeddings = faceNet.predictFaceNet(imageInput);

            // loop over all base faces
            List<double> baseFace = baseFaces[avatar.label];
            var score = faceNet.cosineSimilarity(baseFace, embeddings);
            var category = CategoryDetail(avatar.label, score, face);

            print("Recognitions for Face $faceCount with FaceNet ${category}");
            recs.add(category);

            // var predictionCategoryC = await tfLiteC.predict(imageInput);
            // print("Recognitions for Face $faceCount tfLiteC ${predictionCategoryC}");
            // recs.add(predictionCategoryC);
          }

          faceCount++;
        } catch (ex) {
          print(ex);
        }
      }
    }

    return recs;
  }

/// This needs tflite package which is outdated.
  // processImage(File imageFile) async {
  //   final image = FirebaseVisionImage.fromFile(imageFile);
  //
  //   // Image labelling
  //   // final labeler = FirebaseVision.instance.imageLabeler();
  //   // final List<ImageLabel> labels = await labeler.processImage(image);
  //   // for (ImageLabel label in labels) {
  //   //   final String text = label.text;
  //   //   final String entityId = label.entityId;
  //   //   final double confidence = label.confidence;
  //   // }
  //
  //   final faceDetector = FirebaseVision.instance.faceDetector();
  //   List<Face> faces = await faceDetector.processImage(image);
  //   File croppedFile;
  //   var recs = [];
  //   print("Found ${faces.length} faces");
  //   for (Face face in faces) {
  //     try {
  //       croppedFile = await FlutterNativeImage.cropImage(
  //           imageFile.path,
  //           face.boundingBox.left.toInt(),
  //           face.boundingBox.top.toInt(),
  //           face.boundingBox.width.toInt(),
  //           face.boundingBox.height.toInt());
  //
  //       if (croppedFile != null) {
  //         print('Cropped File: $croppedFile');
  //         var recognitions = await Tflite.runModelOnImage(
  //             path: croppedFile.path, // required
  //             imageMean: 0.0, // defaults to 117.0
  //             imageStd: 255.0, // defaults to 1.0
  //             numResults: 2, // defaults to 5
  //             threshold: 0.2, // defaults to 0.1
  //             asynch: true // defaults to true
  //             );
  //
  //         print('Recognitions');
  //         print("Recognitions ${recognitions}");
  //         recs.add(recognitions[0]);
  //       }
  //     } catch (ex) {
  //       print(ex);
  //     }
  //   }
  //
  //   return recs;
  // }

  /// Gets the model ready for inference on images.
  /// /// This needs tflite package which is outdated.
  // Future<String> loadModel() async {
  //   // final modelFile = await loadModelFromFirebase();
  //   return await loadTFLiteModel(null);
  // }

  /// Loads the model into some TF Lite interpreter.
  /// In this case interpreter provided by tflite plugin.
/// This needs tflite package which is outdated.
  // Future<String> loadTFLiteModel(File modelFile) async {
  //   try {
  //     final appDirectory = await getApplicationDocumentsDirectory();
  //
  //     final labelsData = await rootBundle.load("assets/model/dict.txt");
  //     final labelsFile = await File(appDirectory.path + "/_dict.txt")
  //         .writeAsBytes(labelsData.buffer
  //             .asUint8List(labelsData.offsetInBytes, labelsData.lengthInBytes));
  //
  //     final modelData = await rootBundle.load("assets/model/model.tflite");
  //     final modelFile = await File(appDirectory.path + "/_model.tflite")
  //         .writeAsBytes(modelData.buffer
  //             .asUint8List(modelData.offsetInBytes, modelData.lengthInBytes));
  //
  //     assert(await Tflite.loadModel(
  //           model: modelFile.path,
  //           labels: labelsFile.path,
  //           isAsset: false,
  //         ) ==
  //         "success");
  //     print("Model is loaded");
  //     return "Model is loaded";
  //   } catch (exception) {
  //     print(
  //         'Failed on loading your model to the TFLite interpreter: $exception');
  //     print('The program will not be resumed');
  //     rethrow;
  //   }
  // }

  /// Downloads custom model from the Firebase console and return its file.
  /// located on the mobile device.
  // Future<File> loadModelFromFirebase() async {
  //   try {
  //     // Create model with a name that is specified in the Firebase console
  //     final model = FirebaseCustomRemoteModel('pmln_20209732727');
  //
  //     // Specify conditions when the model can be downloaded.
  //     // If there is no wifi access when the app is started,
  //     // this app will continue loading until the conditions are satisfied.
  //     final conditions = FirebaseModelDownloadConditions(
  //         androidRequireWifi: true, iosAllowCellularAccess: false);
  //
  //     // Create model manager associated with default Firebase App instance.
  //     final modelManager = FirebaseModelManager.instance;
  //
  //     // Begin downloading and wait until the model is downloaded successfully.
  //     await modelManager.download(model, conditions);
  //     assert(await modelManager.isModelDownloaded(model) == true);
  //
  //     // Get latest model file to use it for inference by the interpreter.
  //     var modelFile = await modelManager.getLatestModelFile(model);
  //     assert(modelFile != null);
  //     return modelFile;
  //   } catch (exception) {
  //     print('Failed on loading your model from Firebase: $exception');
  //     print('The program will not be resumed');
  //     rethrow;
  //   }
  // }
}
