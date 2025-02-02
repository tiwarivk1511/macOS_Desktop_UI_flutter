import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DockPage(),
    );
  }
}

// Main Dock Page
class DockPage extends StatefulWidget {
  const DockPage({super.key});

  @override
  _DockPageState createState() => _DockPageState();
}

class _DockPageState extends State<DockPage> {
  List<Map<String, String>> dockApps = [
    {"icon": "assets/start.png", "name": "Start"},
    {"icon": "assets/Launchpad.png", "name": "Launchpad"},
    {"icon": "assets/calendar.png", "name": "Calendar"},
    {"icon": "assets/notes.png", "name": "Notes"},
    {"icon": "assets/settings_macos.png", "name": "Settings"},
    {"icon": "assets/google_chrome_macos.png", "name": "Chrome"},
    {"icon": "assets/xcode_icon.png", "name": "X Code"},
    {"icon": "assets/apple_music_icon.png", "name": "Apple Music"},
  ];

  void handleDockAppDrag(int fromIndex, int toIndex) {
    setState(() {
      final app = dockApps.removeAt(fromIndex);
      dockApps.insert(toIndex, app);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Responsive Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/macos_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Clock positioned at the top right
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, right: 10),
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2.8,
                width: MediaQuery.of(context).size.width / 8,
                child: ClockWidget(),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: HoverableDock(
              dockApps: dockApps,
              onDockAppDrag: handleDockAppDrag,
            ),
          ),
        ],
      ),
    );
  }
}

class HoverableDock extends StatefulWidget {
  final List<Map<String, String>> dockApps;
  final Function(int fromIndex, int toIndex) onDockAppDrag;

  const HoverableDock({
    required this.dockApps,
    required this.onDockAppDrag,
  });

  @override
  _HoverableDockState createState() => _HoverableDockState();
}

class _HoverableDockState extends State<HoverableDock> {
  double? mouseXPosition;
  late List<Map<String, String>> dockApps;

  @override
  void initState() {
    super.initState();
    dockApps =
        List.from(widget.dockApps); // Make a mutable copy for rearrangement
  }

  void rearrangeApps(int fromIndex, int toIndex) {
    setState(() {
      final app = dockApps.removeAt(fromIndex);
      dockApps.insert(toIndex, app);
    });
    widget.onDockAppDrag(fromIndex, toIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          mouseXPosition = event.localPosition.dx;
        });
      },
      onExit: (_) {
        setState(() {
          mouseXPosition = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: dockApps.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> app = entry.value;

            // Calculate proximity-based scaling
            double scale = 1.0;
            if (mouseXPosition != null) {
              double distance = (mouseXPosition! - (index * 70 + 35)).abs();
              scale = max(1.0, 1.5 - (distance / 150));
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(5),
              child: DraggableDockButton(
                app: app,
                onDockAppDrag: rearrangeApps,
                index: index,
                dockAppsLength: dockApps.length,
                scale: scale,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DraggableDockButton extends StatelessWidget {
  final Map<String, String> app;
  final Function(int fromIndex, int toIndex) onDockAppDrag;
  final int index;
  final int dockAppsLength;
  final double scale;

  const DraggableDockButton({
    super.key,
    required this.app,
    required this.onDockAppDrag,
    required this.index,
    required this.dockAppsLength,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(
          app["icon"]!,
          width: 70 * scale,
          height: 70 * scale,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Image.asset(app["icon"]!, width: 50, height: 50),
      ),
      child: DragTarget<int>(
        builder: (context, candidateData, rejectedData) {
          return Tooltip(
            message: app["name"]!,
            verticalOffset: 20,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: scale),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  child: Image.asset(
                    app["icon"]!,
                    width: 50 * value,
                    height: 50 * value,
                  ),
                );
              },
            ),
          );
        },
        onWillAccept: (fromIndex) {
          // Dynamically reorder while dragging
          if (fromIndex != index) {
            // Reorder only if the index is not == 0
            if (fromIndex != 0) {
              onDockAppDrag(fromIndex!, index);
            }
          }
          return true; // Accept the drag
        },
        onAccept: (fromIndex) {
          // Finalize drag when dropped
          if (fromIndex != index) {
            // Reorder only if the index is not == 0
            if (fromIndex != 0) {
              onDockAppDrag(fromIndex, index);
            }
          }
        },
      ),
    );
  }
}

// Analog clock widget
class ClockWidget extends StatefulWidget {
  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late String currentTime;
  late DateFormat _timeFormat;
  late DateTime currentDateTime;

  @override
  void initState() {
    super.initState();
    _timeFormat = DateFormat('hh:mm:ss a'); // 12-hour format with AM/PM
    currentDateTime = DateTime.now();
    currentTime = _getCurrentTime();
    _updateTime();
  }

  // Function to get the current time in 12-hour format as a string
  String _getCurrentTime() {
    return _timeFormat.format(
        currentDateTime); // Use the format method to convert to 12-hour format
  }

  // Function to update the time every second
  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          currentDateTime = DateTime.now();
          currentTime = _getCurrentTime();
        });
        _updateTime();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          // Adding BackdropFilter to create a blur effect
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withOpacity(0), // Transparent overlay to apply blur
            ),
          ),
          // The actual content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.3), // Slightly transparent background
              borderRadius: BorderRadius.circular(12), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Analog clock
                SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  width: MediaQuery.of(context).size.width / 8,
                  child: CustomPaint(
                    painter: ClockPainter(currentDateTime),
                  ),
                ),
                Text(
                  "Current Time",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                // Display the time inside the clock
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      currentTime,
                      style: const TextStyle(
                        fontSize: 28, // Adjust size for visibility
                        fontFamily:
                            'Courier', // Monospaced font for a Mac-like feel
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the analog clock
class ClockPainter extends CustomPainter {
  final DateTime currentTime;
  ClockPainter(this.currentTime);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Paint hourHandPaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    final Paint minuteHandPaint = Paint()
      ..color = Colors.blue.shade200
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    final Paint secondHandPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    // Draw the clock face
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, circlePaint);

    // Draw the clock border
    final Paint borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, borderPaint);

    // Calculate the angle for each hand
    double hourAngle =
        (currentTime.hour % 12 + currentTime.minute / 60) * 30 * pi / 180;
    double minuteAngle =
        (currentTime.minute + currentTime.second / 60) * 6 * pi / 180;
    double secondAngle = currentTime.second * 6 * pi / 180;

    // Draw the hour hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(
        size.width / 2 + 40 * cos(hourAngle - pi / 2),
        size.height / 2 + 40 * sin(hourAngle - pi / 2),
      ),
      hourHandPaint,
    );

    // Draw the minute hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(
        size.width / 2 + 60 * cos(minuteAngle - pi / 2),
        size.height / 2 + 60 * sin(minuteAngle - pi / 2),
      ),
      minuteHandPaint,
    );

    // Draw the second hand
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(
        size.width / 2 + 70 * cos(secondAngle - pi / 2),
        size.height / 2 + 70 * sin(secondAngle - pi / 2),
      ),
      secondHandPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint every time the time changes
  }
}
