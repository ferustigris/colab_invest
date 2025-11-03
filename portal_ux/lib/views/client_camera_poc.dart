import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:portal_ux/widgets/common_app_bar.dart';
import 'package:portal_ux/data/state_notifiers.dart';
import 'package:portal_ux/data/app_constants.dart';

const List<String> testers = [
  "alex.evseenko@gmail.com",
  "ferus.tigris@gmail.com",
  "rustem.zakiev@gmail.com"
];

const int requestDelayMilliseconds = 200;

late List<CameraDescription> _cameras;

class CameraPoc extends StatelessWidget {
  const CameraPoc({super.key});

  Future initCamera() async {
    _cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    StateNotifiers.currentPage.value="CameraPoCViewer";
    return FutureBuilder(
      future: initCamera(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: const CommonAppBar(title: "PoC Client Cam"),
            body: CameraWidget()
          );
        } else if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: const CommonAppBar(title: "PoC Client Cam"),
            body: const Center(child: CircularProgressIndicator())
          );
        } else {
          return Scaffold(
            appBar: const CommonAppBar(title: "PoC Client Cam"),
            body: const Center(child: Text("Init error"))
          );
        }
      }
    );
  }
}

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {

  late CameraController controller;
  bool isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      _cameras.last,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Text("Init Error");
    }
    return Stack(
      children: [
        CameraPreview(controller),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isBroadcasting = !isBroadcasting;
                  });
                },
                child: Text(isBroadcasting ? "Stop Broadcasting" : "Start Broadcasting")
              ),
              SizedBox(height: 16),
              if (isBroadcasting) 
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: StreamBuilder(
                    stream: castLoop(),
                    builder: (context, asyncSnapshot) {
                      if (asyncSnapshot.connectionState == ConnectionState.active)
                      {
                        return Text(asyncSnapshot.data!);
                      } else
                      {
                        return Text(asyncSnapshot.connectionState.toString());
                      }
                    }
                  )
                ), 
              )
            ]
          ),
        )
      ],
    );
  }

  Stream<String> castLoop() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: requestDelayMilliseconds));
      String timeStamp = DateTime.now().toString();
      if (isBroadcasting) {
        try {
          XFile img = await controller.takePicture();
          String envelope = base64Encode(await img.readAsBytes());
          await sendShot(envelope);
        }
        catch (e) {
          print(e.toString());
        }
        yield timeStamp;
      } else {
        yield "no cast";
      }
    }
  }

  Future<String> sendShot(String envelope) async {
    String result = "";
    try {
      final user = StateNotifiers.user.value;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }
      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse(AppConstants.cloudUrlClientCamFunction),
        headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'envelope': envelope
        })
      );
      if (response.statusCode == 200) {
        result = response.body;
      } else {
        throw Exception(
          'Error: ${response.statusCode}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }

}


class CameraViewerWidget extends StatefulWidget {
  const CameraViewerWidget({super.key});

  @override
  State<CameraViewerWidget> createState() => _CameraViewerWidgetState();
}

class _CameraViewerWidgetState extends State<CameraViewerWidget> {

  @override
  Widget build(BuildContext context) {
    StateNotifiers.currentPage.value="CameraPoCViewer";
    return Scaffold(
      appBar: CommonAppBar(title: "Client Cam PoC"),
      body: Center(
        child: StreamBuilder(
          stream: readLoop(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.active)
            {
              return Image.memory(
                asyncSnapshot.data!,
                gaplessPlayback: true
              );
            } else
            {
              return Text(asyncSnapshot.connectionState.toString());
            }
          }
        )
      )
    );
  }

  Stream<Uint8List> readLoop() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: requestDelayMilliseconds));
      try {
        String envelope = await getPicture();
        Uint8List camImage = base64Decode(envelope);
        yield camImage;
      }
      catch (e) {
        print(e.toString());
      }
    }
  }

  Future<String> getPicture() async {
    String result = "";
    try {
      final user = StateNotifiers.user.value;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }
      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse(AppConstants.cloudUrlClientCamFunction),
        headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        result = response.body;
      } else {
        throw Exception(
          'Error: ${response.statusCode}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }

}