import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:window_size/window_size.dart';
//https://shutdown-timer-scripts-cdn.netlify.app/script.vbs
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('ShutdownTimer');
    setWindowMaxSize(const Size(470, 540));
    setWindowMinSize(const Size(470, 540));
  }
  runApp(const MyApp());
}
_write(String code) async {
  String path = 'C:/ProgramData/ShutdownTimer/';
  bool directoryExists = await Directory(path).exists();
  bool fileExists = await File(path).exists();
  if(directoryExists || fileExists) {
    final File file = File('C:/ProgramData/ShutdownTimer/cmd.cmd');
    await file.writeAsString(code);
    OpenFile.open("C:/ProgramData/ShutdownTimer/script.vbs");
  } else {
    final Directory appDocDirFolder = Directory('C:/ProgramData/ShutdownTimer/');
    final Directory appDocDirNewFolder = await appDocDirFolder.create(recursive: true);
    const filename = 'script.vbs';
    var bytes = await rootBundle.load("Assets/script.vbs");
    writeToFile(bytes,'C:/ProgramData/ShutdownTimer/script.vbs');
    final File file = File('C:/ProgramData/ShutdownTimer/cmd.cmd');
    await file.writeAsString(code);
    OpenFile.open("C:/ProgramData/ShutdownTimer/script.vbs");
  }
}
Future<void> writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path).writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShutdownTimer',
      theme: ThemeData(
      ),
      home: const ShutdownTimer()
    );
  }
}
class ShutdownTimer extends StatefulWidget {
  const ShutdownTimer({Key? key}) : super(key: key);
  @override
  _ShutdownTimerState createState() => _ShutdownTimerState();
}
class _ShutdownTimerState extends State<ShutdownTimer>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool isPlaying = false;
  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${controller.duration!.inHours}:${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${count.inHours}:${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  double progress = 1.0;
  void notify() {
    if (countText == '0:00:00') {
      _write('shutdown.exe /s /t 0000');
    }
  }
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60),
    );
    controller.addListener(() {
      notify();
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      } else {
        setState(() {
          progress = 1.0;
          isPlaying = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffe64e1e),
        title: Text('ShutdownTimer'),
        actions: [
          PopupMenuButton(
            // add icon, by default "3 dot" icon
            // icon: Icon(Icons.book)
              itemBuilder: (context){
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("About"),
                  ),
                ];
              },
              onSelected:(value){
                if(value == 0){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                }
              }
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey.shade300,
                    color: Color(0xffe64e1e),
                    value: progress,
                    strokeWidth: 6,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.isDismissed) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          height: 300,
                          child: CupertinoTimerPicker(
                            initialTimerDuration: controller.duration!,
                            onTimerDurationChanged: (time) {
                              setState(() {
                                controller.duration = time;
                              });
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => Text(
                      countText,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.isAnimating) {
                      controller.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      controller.reverse(
                          from: controller.value == 0 ? 1.0 : controller.value);
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  child: RoundButton(
                    icon: isPlaying == true ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.reset();
                    setState(() {
                      isPlaying = false;
                    });
                  },
                  child: RoundButton(
                    icon: Icons.stop,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width*0.9;
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Color(0xffe64e1e),
      ),
      body:
          SingleChildScrollView(
            child:
            Column(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child:
                    Column(children: [
                      Image(image: AssetImage("Assets/logo.png"), width: 150),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text('Version: 1.0.0 "Apfelstrudel" ', style: TextStyle(fontSize: 20, color: Colors.grey)),
                        ],
                      ),
                      Padding(
                          child: Row(
                            children: [
                              InkWell(
                                child: Text('Click here to see OS Infos.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                onTap: () => _write('winver.exe'),
                              )
                            ],
                          ),
                          padding: EdgeInsets.only(top: 10)
                      ),
                      Padding(
                          child: Row(
                            children: [
                              InkWell(
                                child: Container(
                                  width: c_width,
                                  child: Column(
                                    children: [
                                      Text('"ShutdownTimer" is a free Windows application made by felixApps that can shut down your computer according to a timer. It is 100% free and OpenSource.', style: TextStyle(fontSize: 18, color: Colors.grey))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          padding: EdgeInsets.only(top: 20)
                      )
                    ],
                    )
                )
              ],
            ),
          )
    );
  }
}
class RoundButton extends StatelessWidget {
  const RoundButton({
    Key? key,
    required this.icon,
  }) : super(key: key);
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: CircleAvatar(
        backgroundColor: Color(0xffe64e1e),
        radius: 30,
        child: Icon(
          icon,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }
}

//https://youtu.be/XvwX-hmYv0E?t=65