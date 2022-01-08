# Flutter facenet app

This app automatically finds images of people such as politicians (could be anyone!) using on-device facial recognition and then allows the user to take an action, such as delete, on the filtered images. It is written using the Flutter framework. Face detection is performed using Firebase ML Vision and facial recognition is done using the FaceNet ML model.

# How it works

When the app starts up for the first time, it initializes the FaceNet model that is stored in .tflite format and shipped with the application. During the initialization, the model is trained on a pre-defined set of images of the people we are interested in finding. This pre-defined set of images could be of anyone and can be loaded after the app starts. I have included them in the app to keep things simple for now. Besides this, the app initializes the ads, default preferences and local DB.

When a search is performed, the app scans a configurable amount of images in the folder selected by the user. By default, this folder is set to the location of Watsapp. Once a match is found within the acceptable level of confidence, the app generates a yellow box around the matched face and calculates the level of confidence the model has on the matched face. The results from the scan are stored in the local database. All images with a match are displayed to the user in a grid. The app keeps track of all the files scanned previously to avoid scanning them again. It also scans each image for all the target people in one go to save time scanning the same image again for the other targets. An option is given to the user to either mark the scanned image as a wrong match or to delete all the images found to free up space on the device.

The app allows the users to play with some parameters. It allows users to set the number of images to scan in one go. It also allows the users to adjust the confidence level threshold to use for each target person.

# Notes

Modify following files for building the project:

1. main.dart -> Include you test device ID
2. AdManager.dart & android/app/src/main/AndroidManifest.xml -> Add you test ID
3. assets/model -> Add your .tflite model here
4. lib/service/ModelManager.dart -> Add the name of your model in this file
5. Follow the instructions on this [blog](https://medium.com/@estebanuri/converting-sandbergs-facenet-pre-trained-model-to-tensorflow-lite-using-an-unorthodox-way-7ee3a6ed02a3) to generate your model .tflite file.

Feel free to use the code for the following purposes:

1. Learning Flutter
2. Learning to use Tensorflow models with Flutter
3. Enhancing the app to add more features or to improve existing code. I'd love to hear what you make out of it. This can serve as a great starter for school projects. Make sure to check out the Issues tab for ideas.

# GoNawazGo on PlayStore

In case you want to see a demo of how this code works then feel free to download the app from the Google Play Store

[<img src="google-play-badge.png" height="50">](https://play.google.com/store/apps/details?id=com.stackorithm.gng) 
