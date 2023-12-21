import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_app/model/place.dart';
import 'package:place_app/provider/places_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _title;

  void addPlace() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) return;

      _formKey.currentState!.save();

      ref.read(placesProvider.notifier).addPlace(
            Place(
              id: const Uuid().v4(),
              name: _title!,
              image: _selectedImage!,
            ),
          );

      Navigator.of(context).pop();
    }
  }

  void selectPicture(ImageSource imageSource) async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: imageSource, maxWidth: 600);

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    if (context.mounted) Navigator.of(context).pop();
  }

  void showCameraDialogBox() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text(
            "Select Camera Option",
            textAlign: TextAlign.center,
          ),
          children: [
            TextButton(
                onPressed: () => selectPicture(ImageSource.camera),
                child: const Text("Picture from camera")),
            TextButton(
                onPressed: () => selectPicture(ImageSource.gallery),
                child: const Text("Picture from Gallary")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Place"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                maxLength: 50,
                decoration: const InputDecoration(label: Text("Title")),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().isEmpty) {
                    return "Title should be between 1 to 50 characters";
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value;
                },
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3))),
                child: _selectedImage == null
                    ? ElevatedButton.icon(
                        onPressed: showCameraDialogBox,
                        icon: const Icon(Icons.camera),
                        label: const Text("Take Picture"),
                      )
                    : GestureDetector(
                        onTap: showCameraDialogBox,
                        child: Image.file(
                          _selectedImage!,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: addPlace,
                label: const Text("Add Place"),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
