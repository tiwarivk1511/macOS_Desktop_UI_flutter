import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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

  List<Map<String, String>> desktopApps = [];
  Map<String, Offset> desktopPositions = {};
  double desktopStartX = 20;
  double desktopStartY = 20;
  double verticalSpacing = 80;

  void moveAppToDesktop(Map<String, String> app) {
    if (app["name"] == "Start" || app["name"] == "Launchpad") {
      // Prevent moving "Start" and "Launchpad"
      return;
    }
    if (!desktopApps.contains(app) && dockApps.contains(app)) {
      setState(() {
        dockApps.remove(app);
        desktopApps.add(app);

        // Calculate new position for the app
        Offset position = Offset(
          desktopStartX,
          desktopStartY + verticalSpacing * (desktopApps.length - 1),
        );
        desktopPositions[app["icon"]!] = position;
      });
    }
  }

  void moveAppToDock(Map<String, String> app) {
    if (app["name"] == "Start" || app["name"] == "Launchpad") {
      // Prevent moving "Start" and "Launchpad"
      return;
    }
    if (desktopApps.contains(app)) {
      setState(() {
        desktopApps.remove(app);
        desktopPositions.remove(app["icon"]!);
        dockApps.add(app);
      });
    }
  }

  // Function to handle dragging apps within the dock
  void handleDockAppDrag(Map<String, String> app, int fromIndex, int toIndex) {
    setState(() {
      dockApps.removeAt(fromIndex);
      dockApps.insert(toIndex, app);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/macos_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Desktop Area
          Positioned.fill(
            child: DragTarget<Map<String, String>>(
              onAccept: (app) => moveAppToDesktop(app),
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  children: [
                    // Desktop apps
                    ...desktopApps.map((app) {
                      final position = desktopPositions[app["icon"]!]!;
                      return Positioned(
                        left: position.dx,
                        top: position.dy,
                        child: DraggableAppIcon(
                          app: app,
                          onDragEnd: () => moveAppToDock(app),
                        ),
                      );
                    }).toList(),

                    // Desktop Area
                    Positioned.fill(
                      child: DragTarget<Map<String, String>>(
                        onAccept: (app) => moveAppToDesktop(app),
                        builder: (context, candidateData, rejectedData) {
                          return Stack(
                            children: [
                              // Desktop apps
                              ...desktopApps.map((app) {
                                final position =
                                    desktopPositions[app["icon"]!]!;
                                return Positioned(
                                  left: position.dx,
                                  top: position.dy,
                                  child: DraggableAppIcon(
                                    app: app,
                                    onDragEnd: () => moveAppToDock(app),
                                  ),
                                );
                              }).toList(),

                              // Clock and Calendar positioned together
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Clock Widget
                                    ClockWidget(),
                                    SizedBox(
                                        height:
                                            20), // Space between clock and calendar

                                    // Container with decoration for TableCalendar
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      width:
                                          280, // Set the width for the calendar
                                      child: TableCalendar(
                                        firstDay: DateTime.utc(2020, 1, 1),
                                        lastDay: DateTime.utc(2222, 12, 31),
                                        focusedDay: DateTime.now(),
                                        formatAnimationCurve: Curves.easeInOut,
                                        headerStyle: HeaderStyle(
                                          formatButtonVisible: true,
                                          titleCentered: true,
                                          formatButtonShowsNext: true,
                                          formatButtonDecoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          formatButtonTextStyle:
                                              TextStyle(color: Colors.white),
                                        ),
                                        calendarFormat: CalendarFormat.month,
                                        onDaySelected:
                                            (selectedDay, focusedDay) {
                                          // Handle date selection here
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Add the ClockWidget to the top-right corner
                  ],
                );
              },
            ),
          ),
          // Dock Area
          Align(
            alignment: Alignment.bottomCenter,
            child: HoverableDock(
              dockApps: dockApps,
              onDragAccepted: (app) => moveAppToDesktop(app),
              onDockAppDrag: handleDockAppDrag,
            ),
          ),
        ],
      ),
    );
  }
}

class HoverableDock extends StatelessWidget {
  final List<Map<String, String>> dockApps;
  final Function(Map<String, String> app) onDragAccepted;
  final Function(Map<String, String> app, int fromIndex, int toIndex)
      onDockAppDrag;

  const HoverableDock({
    required this.dockApps,
    required this.onDragAccepted,
    required this.onDockAppDrag,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, String>>(
      onAccept: (app) => onDragAccepted(app),
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: dockApps.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> app = entry.value;
                return DraggableDockButton(
                  app: app,
                  onDockAppDrag: (fromIndex, toIndex) =>
                      onDockAppDrag(app, fromIndex, toIndex),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class DraggableDockButton extends StatefulWidget {
  final Map<String, String> app;
  final Function(int fromIndex, int toIndex) onDockAppDrag;

  const DraggableDockButton({required this.app, required this.onDockAppDrag});

  @override
  _DraggableDockButtonState createState() => _DraggableDockButtonState();
}

class _DraggableDockButtonState extends State<DraggableDockButton> {
  bool isHovered = false;

  void showAppPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.app["name"] ?? "App"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Options for ${widget.app["name"]}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAppPopup(context),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Draggable<Map<String, String>>(
          data: widget.app,
          feedback: Material(
            color: Colors.transparent,
            child: Image.asset(widget.app["icon"]!, width: 60, height: 60),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: Image.asset(widget.app["icon"]!, width: 50, height: 50),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: isHovered
                ? const EdgeInsets.symmetric(horizontal: 10.0)
                : EdgeInsets.all(10),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 50),
              scale: isHovered ? 1.8 : 1.2,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App name (CommentBox) floats above the icon when hovered
                        if (isHovered)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 150),
                            bottom:
                                50, // Adjust this value to move the name higher or lower
                            child: Container(
                              alignment: Alignment.center,
                              height: 30,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              constraints: BoxConstraints(
                                maxWidth:
                                    100, // Ensures the name is contained within a fixed width
                              ),
                              child: CommentBox(
                                text: widget.app["name"]!,
                              ),
                            ),
                          ),
                        Image.asset(
                          widget.app["icon"]!,
                          width: isHovered ? 50 : 45,
                          height: isHovered ? 50 : 45,
                        ),

                        // SizeBox to avoid overflow
                        if (isHovered)
                          SizedBox(
                            height: 20,
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Draggable widget to display app icon
class DraggableAppIcon extends StatelessWidget {
  final Map<String, String> app;
  final VoidCallback onDragEnd;

  const DraggableAppIcon({
    required this.app,
    required this.onDragEnd,
  });

  void showAppPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(app["name"] ?? "App"),
        content: Text("Options for ${app["name"]}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAppPopup(context),
      child: Draggable<Map<String, String>>(
        data: app,
        feedback: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(app["icon"]!, width: 50, height: 50),
              Text(app["name"] ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: Image.asset(app["icon"]!, width: 50, height: 50),
        ),
        onDragCompleted: onDragEnd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(app["icon"]!, width: 50, height: 50),
            Text(app["name"] ?? "",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// CommentBox widget to display app name
class CommentBox extends StatelessWidget {
  final String text;

  const CommentBox({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: Colors.white60.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis, // Prevents text from overflowing
        maxLines: 1, // Keeps the text in a single line
      ),
    );
  }
}

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
                  width: 200,
                  height: 200,
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
