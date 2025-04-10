import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'listing_detail_page.dart'; // Replace with your correct path
import './AddListingPage.dart';   // Replace with your correct path

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _SupabaseHomePageState();
}

class _SupabaseHomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final formatCurrency = NumberFormat.simpleCurrency(name: 'INR');
  List<Map<String, dynamic>> listings = [];
  String searchQuery = '';
  int selectedCategory = 0;
  int currentIndex = 0;
  bool canAddListing = false;
  final user = Supabase.instance.client.auth.currentUser;

  final categories = ['All', 'Real Estate', 'Apartment', 'House', 'Motels'];

  @override
  void initState() {
    super.initState();
    fetchListings();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    if (user == null) return;

    // Hardcoded admin and agent emails
    const adminEmails = ['atharvamp04@gmail.com'];

    if (adminEmails.contains(user!.email)) {
      setState(() {
        canAddListing = true;
      });
    }
  }


  Future<void> fetchListings({String? category}) async {
    try {
      dynamic response;

      if (category != null && category != 'All') {
        final categoryResponse = await supabase
            .from('categories')
            .select('id')
            .eq('name', category)
            .maybeSingle();

        if (categoryResponse == null) {
          setState(() {
            listings = [];
          });
          return;
        }

        final categoryId = categoryResponse['id'];

        response = await supabase
            .from('listings')
            .select('id, title, price, address, image_url, categories(name)')
            .eq('category_id', categoryId)
            .limit(10);
      } else {
        response = await supabase
            .from('listings')
            .select('id, title, price, address, image_url, categories(name)')
            .limit(10);
      }

      setState(() {
        listings = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching listings: $e');
    }
  }

  Future<void> searchListings(String query) async {
    if (query.isEmpty) {
      fetchListings(category: categories[selectedCategory]);
      return;
    }

    try {
      final queryBuilder = supabase
          .from('listings')
          .select('id, title, price, address, image_url, categories(name)')
          .ilike('title', '%$query%');

      if (categories[selectedCategory] != 'All') {
        final categoryResponse = await supabase
            .from('categories')
            .select('id')
            .eq('name', categories[selectedCategory])
            .maybeSingle();

        if (categoryResponse != null) {
          final categoryId = categoryResponse['id'];
          queryBuilder.eq('category_id', categoryId);
        }
      }

      final response = await queryBuilder;

      setState(() {
        listings = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error searching listings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (query) {
                        searchQuery = query;
                        searchListings(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_alt, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Category Filter
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final isSelected = index == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = index;
                          searchQuery = '';
                        });
                        fetchListings(category: categories[index]);
                      },
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Listings Grid
            Expanded(
              child: listings.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: listings.length,
                itemBuilder: (_, index) {
                  final item = listings[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListingDetailPage(listingId: item['id']),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              item['image_url'] ?? '',
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 130,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons
                                      .image_not_supported_outlined),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              formatCurrency.format(item['price']),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: Text(
                              item['address'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);

          if (canAddListing && index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddListingPage()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Inbox"),
          if (canAddListing)
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: "Add Listing",
            ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.timeline), label: "Activity"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
