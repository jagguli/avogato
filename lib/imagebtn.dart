import 'dart:convert';
import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final String imageBase64;
  final VoidCallback? onPressed;
  final String label;

  ImageButton({required this.imageBase64, this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue,
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.scaleDown,
                  image: imageBase64 != "default"
                      ? MemoryImage(base64Decode(imageBase64))
                      : (AssetImage('images/default_image.png')
                          as ImageProvider),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            label ?? '',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
