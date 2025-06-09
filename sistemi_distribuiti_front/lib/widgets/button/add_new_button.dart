import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddNewButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AddNewButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  _AddNewButtonState createState() => _AddNewButtonState();
}

class _AddNewButtonState extends State<AddNewButton>
    with SingleTickerProviderStateMixin {
  bool isRotated = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isRotated = !isRotated;
        });
        widget.onPressed();
      },
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 300),
        turns: isRotated ? 0.25 : 0.0, // 90 degrees (1/4 turn)
        child: SvgPicture.string(
          '''
          <svg xmlns="http://www.w3.org/2000/svg" width="50px" height="50px" viewBox="0 0 24 24">
            <path d="M12 22C17.5 22 22 17.5 22 12C22 6.5 17.5 2 12 2C6.5 2 2 6.5 2 12C2 17.5 6.5 22 12 22Z"
              stroke="#60A5FA" fill="none" stroke-width="1.5"/>
            <path d="M8 12H16" stroke="#60A5FA" stroke-width="1.5"/>
            <path d="M12 16V8" stroke="#60A5FA" stroke-width="1.5"/>
          </svg>
          ''',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
