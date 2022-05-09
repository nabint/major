import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_window/desktop_window.dart';
import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_enhancer/image_repository.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ButtonState buttonState = ButtonState.idle;

  FilePickerResult? result;
  File? file;
  // Uint8List? bytes;
  String? enhancedImgUrl;

  Future<void> downloadImage(String imageUrl) async {
    try {
      final http.Response r = await http.get(
        Uri.parse(imageUrl),
      );

      final data = r.bodyBytes;
      final base64data = base64Encode(data);

      final a = html.AnchorElement(href: 'data:image/jpg;base64,$base64data');

      a.download = 'download.png';

      a.click();
      a.remove();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await DesktopWindow.setFullScreen(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // file != null
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("Original Image"),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 400,
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        child: InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(0.0),
                          minScale: 0.1,
                          maxScale: 10,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: (file != null)
                              ? Image.file(
                                  file!,
                                  fit: BoxFit.contain,
                                )
                              : Container(),
                          // ),
                        ),
                      ),
                    ],
                  ),
                  // : Container(
                  //     height: 400,
                  //     width: 400,
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey.withOpacity(0.4),
                  //     ),
                  //     child: const Center(
                  //       child: Text("Upload File Using Button Below"),
                  //     ),
                  //   ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("Enhanced Image"),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 400,
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        child: InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(0.0),
                          minScale: 0.1,
                          maxScale: 10,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: (enhancedImgUrl != null)
                              ? Image.network(
                                  enhancedImgUrl!,
                                  fit: BoxFit.contain,
                                )
                              : Container(),
                          // ),
                        ),
                      ),
                      // TextButton.icon(
                      //     onPressed: () {
                      //       downloadImage(
                      //           "http://15.206.253.19:8080/super_res/20220508120113227678.jpg");
                      //     },
                      //     icon: const Icon(Icons.download),
                      //     label: const Text("Download")),
                    ],
                  )
                ],
              ),
              const SizedBox(
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
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      color: Colors.red.shade300),
                  ButtonState.success: IconedButton(
                      text: "Success",
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      color: Colors.green.shade400)
                },
                onPressed: _selectImage,
                state: ButtonState.idle,
              ),
              const SizedBox(
                height: 40,
              ),
              ProgressButton.icon(
                maxWidth: 200.0,
                iconedButtons: {
                  ButtonState.idle: IconedButton(
                      text: "Enhance Image",
                      icon: const Icon(Icons.send, color: Colors.white),
                      color: Colors.deepPurple.shade500),
                  ButtonState.loading: IconedButton(
                      text: "Loading", color: Colors.deepPurple.shade700),
                  ButtonState.fail: IconedButton(
                      text: "Failed",
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      color: Colors.red.shade300),
                  ButtonState.success: IconedButton(
                      text: "Success Enhance Again",
                      icon: const Icon(
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
      ),
    );
  }

  _selectImage() async {
    result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // if (kIsWeb) {
      //   bytes = result!.files.first.bytes;
      // } else {
      file = File(result!.files.single.path!);
      // }
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please Upload an Image!'),
      ));
      log("Cancelled");
    }
  }
}
