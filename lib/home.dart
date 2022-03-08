import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_enhancer/image_repository.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ButtonState buttonState = ButtonState.idle;

  FilePickerResult? result;
  File? file;
  String? enhancedImgUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                file != null
                    ? Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text("Original Image"),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 400,
                            width: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              image: DecorationImage(
                                image: FileImage(file!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: 400,
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        child: const Center(
                          child: Text("Upload File Using Button Below"),
                        ),
                      ),
                SizedBox(
                  width: 20,
                ),
                enhancedImgUrl != null
                    ? Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text("Enhanced Image"),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 400,
                            width: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              image: DecorationImage(
                                image: NetworkImage(enhancedImgUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            ProgressButton.icon(
              iconedButtons: {
                ButtonState.idle: IconedButton(
                    text: "Select Image",
                    icon: const Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    color: Colors.amber.shade500),
                ButtonState.loading: IconedButton(
                    text: "Loading", color: Colors.deepPurple.shade700),
                ButtonState.fail: IconedButton(
                    text: "Failed",
                    icon: Icon(Icons.cancel, color: Colors.white),
                    color: Colors.red.shade300),
                ButtonState.success: IconedButton(
                    text: "Success",
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    color: Colors.green.shade400)
              },
              onPressed: _selectImage,
              state: ButtonState.idle,
            ),
            SizedBox(
              height: 40,
            ),
            ProgressButton.icon(
              maxWidth: 200.0,
              iconedButtons: {
                ButtonState.idle: IconedButton(
                    text: "Enhance Image",
                    icon: Icon(Icons.send, color: Colors.white),
                    color: Colors.deepPurple.shade500),
                ButtonState.loading: IconedButton(
                    text: "Loading", color: Colors.deepPurple.shade700),
                ButtonState.fail: IconedButton(
                    text: "Failed",
                    icon: Icon(Icons.cancel, color: Colors.white),
                    color: Colors.red.shade300),
                ButtonState.success: IconedButton(
                    text: "Success Enhance Again",
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    color: Colors.green.shade400)
              },
              onPressed: () => _uploadImage(context),
              state: buttonState,
            ),
          ],
        ),
      ),
    );
  }

  _selectImage() async {
    result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = File(result!.files.single.path!);
    }
    setState(() {});
  }

  _uploadImage(BuildContext context) async {
    if (file != null) {
      setState(
        () {
          buttonState = ButtonState.loading;
        },
      );
      enhancedImgUrl = await ImageRepository().uploadImage(file!);
      setState(
        () {
          buttonState = ButtonState.success;
        },
      );
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please Upload an Image!'),
      ));
      log("Cancelled");
    }
  }
}
