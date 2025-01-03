import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatelessWidget {
  final Rx<XFile?> selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onTakePicture;

  const PhotoPicker({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.onTakePicture,
  });

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
              onTap: () => _showImageSourceBottomSheet(context),
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

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue,),
              title: const Text("Take Picture"),
              onTap: () {
                Navigator.of(context).pop();
                onTakePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.blue,),
              title: const Text("Pick from Gallery"),
              onTap: () {
                Navigator.of(context).pop();
                onPickImage();
              },
            ),
          ],
        );
      },
    );
  }
}
