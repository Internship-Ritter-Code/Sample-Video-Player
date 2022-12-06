import 'dart:io';

import 'package:example_video_player/views/utils/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => VideoPlayerViewState();
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  File? file;
  TextEditingController controller = TextEditingController();
  VideoPlayerController? videoPlayerController;
  double duration = 0;
  List<bool> showIcon = [false, false, true];

  @override
  void dispose() {
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Player"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              controller: controller,
              onTap: () async {
                var file = await FilePick().pickAFile();
                if (file != null) {
                  controller.text = path.basename(file.path);
                  this.file = file;
                  videoPlayerController = VideoPlayerController.file(file);
                  await videoPlayerController!.initialize();
                  setState(() {});
                  if (videoPlayerController!.value.isInitialized) {
                    print("terinitialize");
                  }
                }
              },
              decoration: InputDecoration(
                isDense: true,
                hintText: "Pilih File",
              ),
            ),
            if (videoPlayerController != null)
              GestureDetector(
                onTap: () async {
                  if (videoPlayerController!.value.isPlaying) {
                    videoPlayerController!.pause();
                  } else {
                    videoPlayerController!.play();
                  }
                  if (showIcon[2] == false) {
                    showIcon[2] = true;
                  }
                  setState(() {});
                  await Future.delayed(
                    Duration(
                      seconds: 1,
                    ),
                  );
                  showIcon[2] = false;
                  setState(() {});
                },
                child: AspectRatio(
                  aspectRatio: videoPlayerController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(
                        videoPlayerController!,
                      ),
                      AnimatedOpacity(
                        opacity: showIcon[2] == true ? 1 : 0,
                        duration: Duration(
                          milliseconds: 400,
                        ),
                        child: Icon(
                          videoPlayerController!.value.isPlaying == false
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                      FutureBuilder(
                        future: videoPlayerController!.position,
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onDoubleTap: () async {
                                          var total =
                                              snapshot.data!.inMicroseconds -
                                                  5000000;
                                          if (total <= 0) {
                                            total = 0;
                                          }
                                          await videoPlayerController!.seekTo(
                                            Duration(
                                              microseconds: total,
                                            ),
                                          );
                                          setState(() {});
                                          showIcon[0] = true;
                                          setState(() {});
                                          await Future.delayed(
                                            Duration(
                                              seconds: 1,
                                            ),
                                          );
                                          showIcon[0] = false;
                                          setState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: AnimatedOpacity(
                                            opacity:
                                                showIcon[0] == false ? 0 : 1,
                                            duration: Duration(
                                              microseconds: 100,
                                            ),
                                            child: Icon(
                                              Icons.replay_5,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(""),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onDoubleTap: () async {
                                          var total =
                                              snapshot.data!.inMicroseconds +
                                                  5000000;
                                          if (total >=
                                              videoPlayerController!.value
                                                  .duration.inMicroseconds) {
                                            total = videoPlayerController!
                                                .value.duration.inMicroseconds;
                                          }
                                          await videoPlayerController!.seekTo(
                                            Duration(
                                              microseconds: total,
                                            ),
                                          );
                                          showIcon[1] = true;
                                          setState(() {});
                                          await Future.delayed(
                                            Duration(
                                              seconds: 1,
                                            ),
                                          );
                                          showIcon[1] = false;
                                          setState(() {});
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: AnimatedOpacity(
                                            opacity:
                                                showIcon[1] == false ? 0 : 1,
                                            duration: Duration(
                                              microseconds: 100,
                                            ),
                                            child: Icon(
                                              Icons.forward_5,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text("");
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (videoPlayerController != null)
              StreamBuilder(
                stream: videoPlayerController!.position
                    .asStream()
                    .asBroadcastStream(),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Row(
                          children: [
                            Flexible(
                              child: Slider(
                                value: snapshot.data!.inMicroseconds.toDouble(),
                                min: 0.0,
                                max: videoPlayerController!
                                    .value.duration.inMicroseconds
                                    .toDouble(),
                                onChanged: (e) async {
                                  await videoPlayerController!.seekTo(
                                    Duration(
                                      microseconds: e.toInt(),
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                            Text(
                              snapshot.data.toString(),
                            ),
                          ],
                        )
                      // ? Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         snapshot.data!.inMicroseconds.toString(),
                      //       ),
                      //       Text(
                      //         videoPlayerController!
                      //             .value.duration.inMicroseconds
                      //             .toString(),
                      //       ),
                      //     ],
                      //   )
                      : Container();
                },
              ),
          ],
        ),
      ),
    );
  }
}
