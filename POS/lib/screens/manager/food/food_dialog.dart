import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'food_service.dart';

class FoodDialog {
  static void showAddFoodDialog(BuildContext context, Function onSuccess) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    XFile? pickedImage;

    final service = FoodService();

    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      pickedImage = image;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Food"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  await pickImage();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pickedImage == null ? "No image selected" : "Image selected")));
                },
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || priceController.text.isEmpty || categoryController.text.isEmpty || pickedImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields and select image")));
                return;
              }
              final result = await service.uploadFood(
                name: nameController.text.trim(),
                desc: descController.text.trim(),
                price: priceController.text.trim(),
                category: categoryController.text.trim(),
                image: pickedImage!,
              );

              if (result['success']) {
                onSuccess();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
