import 'package:assignment/features/core/dock.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: instructionText(),
            ),
            Center(
              child: Dock(
                items: const [
                  Icons.chrome_reader_mode,
                  Icons.person,
                  Icons.message,
                  Icons.call,
                  Icons.camera,
                  Icons.photo,
                  Icons.gamepad,
                  Icons.square_foot_sharp,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Widget instructionText() {
  return Column(
    children: [
      Text(
        "INSTRUCTIONS",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            children: [
              const TextSpan(
                text:
                    "\n1. The Mouse Pointer [Cursor] acts as Center and the point of impact and not the hovered icon\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: "2. Drag an icon to see dynamic spacing effect\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "3. When dragging, other icons will ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "move away",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: " from the cursor\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const TextSpan(
                text: "4. Release to drop the icon in its new position\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "5. Icons will ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "automatically rearrange",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: " based on cursor position",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextSpan(
                text: "\n # The animations might feel fast  ",
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: "automatically rearrange",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: " drag and drop",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
