import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'dart:io';

class ListingDetailPage extends StatefulWidget {
  final String listingId;

  const ListingDetailPage({super.key, required this.listingId});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  final supabase = Supabase.instance.client;
  final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');
  Map<String, dynamic>? listing;
  List<String> images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchListingDetails();
  }

  Future<void> fetchListingDetails() async {
    try {
      final response = await supabase
          .from('listings')
          .select('id, title, price, address, image_url, description')
          .eq('id', widget.listingId)
          .single();

      debugPrint('Raw image URLs: ${response['image_url']}');

      setState(() {
        listing = response;
        final dynamic imageUrls = response['image_url'];

        if (imageUrls is List) {
          images = imageUrls
              .map((url) => url.toString().replaceAll("listing-image//", "listing-image/"))
              .toList();
        } else if (imageUrls is String) {
          // In case image_url is a comma-separated string
          images = imageUrls.split(',').map((e) => e.trim()).toList();
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error fetching listing details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (listing == null) {
      return const Scaffold(
        body: Center(child: Text('Listing not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search listings...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: images.isNotEmpty
                      ? ImageSlideshow(
                    width: double.infinity,
                    height: 250,
                    initialPage: 0,
                    indicatorColor: Colors.blue,
                    indicatorBackgroundColor: Colors.grey,
                    autoPlayInterval: 3000,
                    isLoop: true,
                    children: images.map((imageUrl) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullImageView(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                      : Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 40)),
                  ),

                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing!['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency.format(
                          int.tryParse(listing?['price']?.toString() ?? '0') ?? 0,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              listing!['address'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing!['description'] ?? 'No description available.',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => openWhatsApp(
                  '919321852718',
                  listing!['title'] ?? '',
                  formatCurrency.format(
                    int.tryParse(listing?['price']?.toString() ?? '0') ?? 0,
                  ),
                  listing!['address'] ?? '',
                ),
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                label: const Text("WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => sendEmail(
                  'atharvamp04@gmail.com',
                  listing!['title'] ?? '',
                  formatCurrency.format(
                    int.tryParse(listing?['price']?.toString() ?? '0') ?? 0,
                  ),
                  listing!['address'] ?? '',
                ),
                icon: const Icon(Icons.mail_outline),
                label: const Text("Email"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openWhatsApp(String phoneNumber, String listingName, String price, String address) async {
  final message = 'Hi, I am interested in your listing:\n'
      '🏡 $listingName\n'
      '💰 Price: $price\n'
      '📍 Address: $address';

  final encodedUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

  if (Platform.isAndroid) {
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: encodedUrl,
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    try {
      await intent.launch();
    } catch (e) {
      debugPrint("❌ Could not launch WhatsApp: $e");
    }
  } else {
    debugPrint('❌ WhatsApp launch only supported on Android for now.');
  }
}

void sendEmail(String email, String listingName, String price, String address) async {
  final String subject = Uri.encodeComponent('Inquiry about $listingName');
  final String body = Uri.encodeComponent(
    'Hi,\n\nI am interested in your listing:\n\n'
        '🏡 $listingName\n'
        '💰 Price: $price\n'
        '📍 Address: $address\n\n'
        'Please let me know the next steps.\nThank you!',
  );

  final Uri emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

  if (Platform.isAndroid) {
    final intent = AndroidIntent(
      action: 'android.intent.action.SENDTO',
      data: emailUri.toString(),
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    try {
      await intent.launch();
    } catch (e) {
      debugPrint("❌ Could not launch email intent on Android: $e");
    }
  } else {
    debugPrint("❌ Email launch only supported on Android for now.");
  }
}

class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 100),
          ),
        ),
      ),
    );
  }
}
