import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool isPlaying = false;
  double progress = 1.00;
  bool hasStarted = false;
  int currentIndex = 0;
  bool isSoundOn = true;
  bool isRingtonePlaying = false;

  final player = AudioPlayer();

  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget buildDotText() {
    return Column(
      children: dotText.split('\n').map<Widget>((line) {
        if (dotText.indexOf(line) == 0) {
          // First line
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              line,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              line,
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 18,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  String get dotText {
    //print('Current Index: $currentIndex, Has Started: $hasStarted');
    if (!hasStarted) {
      return 'Time to eat mindfully \n  It\'s simple: eat slowly for ten minutes, rest\n for five, then finish your meal';
    } else {
      switch (currentIndex) {
        case 0:
          return 'Nom nom :) \n You have 10 minutes to eat before the pause. \n Focus on eating slowly';
        case 1:
          return 'Break Time\n Take a five-minute break to check in on your \n level of fullness';
        case 2:
          return 'Finish your meal \n You can eat until you feel full';
        default:
          return '';
      }
    }
  }

  void notify() {
    if (currentIndex <= 2) {
      if (controller.duration! * controller.value <=
              const Duration(seconds: 5) &&
          isSoundOn &&
          !isRingtonePlaying) {
        playAudio();
        setState(() {
          isRingtonePlaying = true;
        });
      }

      if (countText == '00:00') {
        player.stop();
        setState(() {
          isRingtonePlaying = false;
        });

        int nextIndex = currentIndex + 1;

        if (hasStarted && nextIndex <= 2) {
          setState(() {
            currentIndex = nextIndex;
          });
        }
        if (nextIndex == 1) {
          controller.reverse(from: 1.0);
        }
      }
    }
  }

  void playAudio() async {
    await player.play(
      AssetSource('countdown_tick.mp3'),
    );
  }

  @override
  void initState() {
    super.initState();

    player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          isRingtonePlaying = false;
        });
      }
    });

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
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
        notify();
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 200.0;
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    const borderWidth = 2.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Meal Timer'),
        backgroundColor: const Color.fromARGB(145, 55, 1, 66),
      ),
      backgroundColor: const Color.fromARGB(145, 55, 1, 66),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color:
                      currentIndex == 0 ? Colors.white : Colors.grey.shade400,
                ),
                const SizedBox(
                  width: 2,
                ),
                Icon(
                  Icons.circle,
                  color:
                      currentIndex == 1 ? Colors.white : Colors.grey.shade400,
                ),
                const SizedBox(
                  width: 2,
                ),
                Icon(
                  Icons.circle,
                  color:
                      currentIndex == 2 ? Colors.white : Colors.grey.shade400,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          buildDotText(),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size + 70,
                  height: size + 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 30,
                    ),
                  ),
                ),
                Container(
                  width: size + 30,
                  height: size + 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 20,
                    ),
                  ),
                ),
                SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: size,
                        height: size,
                        child: CircularProgressIndicator(
                          value: progress,
                          color: Colors.green,
                          strokeWidth: 8,
                        ),
                      ),
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: Image.asset("assets/images/radial_scale.png")
                                .image,
                            colorFilter: ColorFilter.mode(
                              Colors.green.withOpacity(
                                progress,
                              ),
                              BlendMode.srcATop,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (!controller.isAnimating) {
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
                          child: Container(
                            width: size - 40,
                            height: size - 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    countText,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'minutes remaining',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: isSoundOn,
                        onChanged: (value) {
                          setState(() {
                            isSoundOn = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                      ),
                      Text(
                        isSoundOn ? 'Sound On' : 'Sound Off',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (!hasStarted)
                    TextButton(
                      onPressed: () {
                        controller.reverse(
                            from:
                                controller.value == 0 ? 1.0 : controller.value);
                        setState(() {
                          isPlaying = true;
                          hasStarted = true;
                        });
                      },
                      child: SizedBox(
                        width: buttonWidth,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightGreenAccent,
                                Colors.green.shade700,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Center(
                              child: Text(
                                'START',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (hasStarted)
                    Center(
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              if (controller.isAnimating) {
                                controller.stop();
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                controller.reverse(
                                    from: controller.value == 0
                                        ? 1.0
                                        : controller.value);
                                setState(() {
                                  isPlaying = true;
                                });
                              }
                            },
                            child: SizedBox(
                              width: buttonWidth,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.lightGreenAccent,
                                      Colors.green.shade700,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Text(
                                      isPlaying ? 'PAUSE' : 'RESUME',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              player.stop();
                              controller.reset();
                              setState(() {
                                isPlaying = false;
                                hasStarted = false;
                                currentIndex = 0;
                              });
                            },
                            child: SizedBox(
                              width: buttonWidth,
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: borderWidth,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Text(
                                      "LET'S STOP I'M FULL NOW",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
