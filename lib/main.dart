// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const DockPage(),
//     );
//   }
// }
//
// // Main Dock Page
// class DockPage extends StatefulWidget {
//   const DockPage({super.key});
//
//   @override
//   _DockPageState createState() => _DockPageState();
// }
//
// class _DockPageState extends State<DockPage> {
//   // Sample list of dock apps with corresponding icons
//   List<Map<String, String>> dockApps = [
//     {"icon": "assets/start.png", "name": "Start"},
//     {"icon": "assets/Launchpad.png", "name": "Launchpad"},
//     {"icon": "assets/calendar.png", "name": "Calendar"},
//     {"icon": "assets/notes.png", "name": "Notes"},
//     {"icon": "assets/settings_macos.png", "name": "Settings"},
//     {"icon": "assets/google_chrome_macos.png", "name": "Chrome"},
//     {"icon": "assets/xcode_icon.png", "name": "X Code"},
//     {"icon": "assets/apple_music_icon.png", "name": "Apple Music"},
//   ];
//
//   // Function to handle the drag-and-drop action
//   void handleDockAppDrag(int fromIndex, int toIndex) {
//     setState(() {
//       final app =
//           dockApps.removeAt(fromIndex); // Remove the app from its old position
//       dockApps.insert(toIndex, app); // Insert the app at its new position
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image for the dock
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/macos_bg.jpg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//
//           Align(
//             alignment: Alignment.topRight,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 30, right: 10),
//               child: SizedBox(
//                 height: 300,
//                 width: 300,
//                 child: ClockWidget(),
//               ),
//             ),
//           ),
//           // Dock Area
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: HoverableDock(
//               dockApps: dockApps,
//               onDockAppDrag: handleDockAppDrag,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // The dock containing app icons
// class HoverableDock extends StatelessWidget {
//   final List<Map<String, String>> dockApps;
//   final Function(int fromIndex, int toIndex) onDockAppDrag;
//
//   const HoverableDock({
//     required this.dockApps,
//     required this.onDockAppDrag,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.8),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal, // Enable horizontal scrolling
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: dockApps.asMap().entries.map((entry) {
//             int index = entry.key; // Current index of the app
//             Map<String, String> app = entry.value; // App data
//             return DraggableDockButton(
//               app: app,
//               onDockAppDrag: onDockAppDrag, // Pass the drag function
//               index: index,
//               dockAppsLength:
//                   dockApps.length, // Pass the length of the dockApps
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
//
// // Draggable Dock Button
// class DraggableDockButton extends StatefulWidget {
//   final Map<String, String> app; // App data
//   final Function(int fromIndex, int toIndex)
//       onDockAppDrag; // Function to handle drag-and-drop
//   final int index; // Current index
//   final int dockAppsLength;
//
//   const DraggableDockButton({
//     super.key,
//     required this.app,
//     required this.onDockAppDrag,
//     required this.index,
//     required this.dockAppsLength,
//   });
//
//   @override
//   _DraggableDockButtonState createState() => _DraggableDockButtonState();
// }
//
// class _DraggableDockButtonState extends State<DraggableDockButton> {
//   bool isHovered = false; // Track hover state
//
//   @override
//   Widget build(BuildContext context) {
//     double iconSize = isHovered ? 70.0 : 50.0; // Increase size on hover
//
//     return MouseRegion(
//       onEnter: (_) => setState(() => isHovered = true), // Mouse enters
//       onExit: (_) => setState(() => isHovered = false), // Mouse exits
//       child: Draggable<int>(
//         data: widget.index, // Pass the current index for dragging
//         feedback: Material(
//           color: Colors.transparent,
//           child: Image.asset(widget.app["icon"]!,
//               width: iconSize, height: iconSize), // Dragged icon
//         ),
//         childWhenDragging: widget.index == 0 // Keep the 0th icon intact
//             ? Container() // Optionally, you may want an empty container
//             : Opacity(
//                 opacity: 0.5, // Make original icon semi-transparent
//                 child: Image.asset(widget.app["icon"]!,
//                     width: 50, height: 50), // Original icon size
//               ),
//         onDragEnd: (details) {
//           // Add a condition to prevent dragging the first item
//           if (widget.index == 0)
//             return; // Return early if dragging the first item
//
//           final RenderBox renderBox =
//               context.findRenderObject() as RenderBox; // Get the render box
//           double dx = renderBox
//               .globalToLocal(details.offset)
//               .dx; // Calculate drag X position
//
//           // Width of each item in the dock for index calculation
//           double itemWidth = 70; // Total width including margins
//           int newIndex =
//               (dx / itemWidth).floor(); // Calculate target index based on drag
//
//           // Clamp new index to be within the range of items in the dock
//           newIndex = newIndex.clamp(
//               1,
//               widget.dockAppsLength -
//                   1); // Only allow moving within 1 to length - 1
//
//           // Move the dragged item if the new index is different from the current index
//           if (widget.index != newIndex) {
//             widget.onDockAppDrag(
//                 widget.index, newIndex); // Update order of items
//           }
//         },
//         child: DragTarget<int>(
//           builder: (context, candidateData, rejectedData) {
//             return Tooltip(
//               // Add Tooltip widget
//               message: widget.app["name"]!, // Set message to app name
//               verticalOffset:
//                   20, // Optional: adjust vertical positioning of the tooltip
//               child: Container(
//                 margin: const EdgeInsets.all(5),
//                 child: Image.asset(
//                   widget.app["icon"]!,
//                   width: iconSize, // Use dynamic size based on hover
//                   height: iconSize, // Use dynamic size based on hover
//                 ), // Display app icon
//               ),
//             );
//           },
//           onAccept: (data) {
//             if (data != widget.index && data != 0) {
//               // Prevent accepting from the 0 index
//               widget.onDockAppDrag(data, widget.index); // Update order of items
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
// // CommentBox widget to display the app name in the dock
// class CommentBox extends StatelessWidget {
//   final String text;
//
//   const CommentBox({Key? key, required this.text}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(1.0), // Padding around the text
//       decoration: BoxDecoration(
//         color: Colors.white60.withOpacity(0.5), // Semi-transparent background
//         borderRadius: BorderRadius.circular(4.0), // Rounded corners
//       ),
//       child: Text(
//         text,
//         textAlign: TextAlign.center, // Center the text
//         style: const TextStyle(
//             color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
//         overflow: TextOverflow.ellipsis, // Prevent overflow text
//         maxLines: 1, // Limit to one line
//       ),
//     );
//   }
// }

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
                height: 290,
                width: 260,
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

class HoverableDock extends StatelessWidget {
  final List<Map<String, String>> dockApps;
  final Function(int fromIndex, int toIndex) onDockAppDrag;

  const HoverableDock({
    required this.dockApps,
    required this.onDockAppDrag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: dockApps.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> app = entry.value;
            return DraggableDockButton(
              app: app,
              onDockAppDrag: onDockAppDrag,
              index: index,
              dockAppsLength: dockApps.length,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DraggableDockButton extends StatefulWidget {
  final Map<String, String> app;
  final Function(int fromIndex, int toIndex) onDockAppDrag;
  final int index;
  final int dockAppsLength;

  const DraggableDockButton({
    super.key,
    required this.app,
    required this.onDockAppDrag,
    required this.index,
    required this.dockAppsLength,
  });

  @override
  _DraggableDockButtonState createState() => _DraggableDockButtonState();
}

class _DraggableDockButtonState extends State<DraggableDockButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    double iconSize = isHovered ? 70.0 : 50.0;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Draggable<int>(
        data: widget.index,
        feedback: Material(
          color: Colors.transparent,
          child: Image.asset(widget.app["icon"]!,
              width: iconSize, height: iconSize),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: Image.asset(widget.app["icon"]!, width: 50, height: 50),
        ),
        onDragEnd: (details) {
          if (widget.index == 0) return;

          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          double dx = renderBox.globalToLocal(details.offset).dx;

          double itemWidth = 70;
          int newIndex = (dx / itemWidth).floor();

          newIndex = newIndex.clamp(1, widget.dockAppsLength - 1);

          if (widget.index != newIndex) {
            widget.onDockAppDrag(widget.index, newIndex);
          }
        },
        child: DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            return Tooltip(
              message: widget.app["name"]!,
              verticalOffset: 20,
              child: Container(
                margin: const EdgeInsets.all(5),
                child: Image.asset(
                  widget.app["icon"]!,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            );
          },
          onAccept: (data) {
            if (data != widget.index && data != 0) {
              widget.onDockAppDrag(data, widget.index);
            }
          },
        ),
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
