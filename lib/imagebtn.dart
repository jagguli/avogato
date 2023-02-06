
import 'dart:convert';
import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final String imageBase64;
  final VoidCallback? onPressed;
  final Widget? child;

  ImageButton({required this.imageBase64, this.onPressed, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue,
            offset: Offset(1, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: imageBase64 != "default"
                  ? MemoryImage(base64Decode(imageBase64!))
                  : (AssetImage('images/default_image.png') as ImageProvider), 
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
