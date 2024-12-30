import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatelessWidget {
  final Rx<XFile?> selectedImage;
  final VoidCallback onPickImage;

  const PhotoPicker({
    Key? key,
    required this.selectedImage,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Photo", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Center(
          child: Obx(() {
            return GestureDetector(
              onTap: onPickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: selectedImage.value == null
                    ? const Icon(Icons.camera_alt, color: Colors.grey, size: 50)
                    : Image.file(File(selectedImage.value!.path)),
              ),
            );
          }),
        ),
      ],
    );
  }
}
