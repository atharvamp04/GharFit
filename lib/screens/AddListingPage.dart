import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isSubmitting = false;
  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      final imageName = path.basename(image.path);
      final fileExt = path.extension(image.path);
      final mimeType = lookupMimeType(image.path);

      final fileBytes = await image.readAsBytes();

      final storageResponse = await supabase.storage
          .from('listing-image') // Replace with your bucket name
          .uploadBinary(
        'listings/$imageName',
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType),
      );

      if (storageResponse.isEmpty) return null;

      final imageUrl = supabase.storage
          .from('listing-image')
          .getPublicUrl('listings/$imageName');

      return imageUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> addListing() async {
    if (!_formKey.currentState!.validate() || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick an image')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final imageUrl = await uploadImage(selectedImage!);
      if (imageUrl == null) throw Exception('Image upload failed');

      await supabase.from('listings').insert({
        'title': titleController.text.trim(),
        'price': int.tryParse(priceController.text.trim()) ?? 0,
        'address': addressController.text.trim(),
        'image_url': imageUrl,
        'description': descriptionController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listing added successfully")),
      );

      _formKey.currentState!.reset();
      setState(() => selectedImage = null);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add listing")),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Listing")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: selectedImage != null
                      ? Image.file(selectedImage!, fit: BoxFit.cover)
                      : const Center(child: Text('Tap to pick an image')),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : addListing,
                child: isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Add Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
