import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'listing_detail_page.dart'; // Replace with your correct path
import './AddListingPage.dart';   // Replace with your correct path
import 'package:google_fonts/google_fonts.dart';



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
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();


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
            // 🔍 Search & Filter Bar
            // 🔍 Logo + Dynamic Search & Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // 🏠 App Logo
                  Image.asset(
                    'assets/logo/logo.png', // Replace with your asset path
                    height: 32,
                  ),

                  const SizedBox(width: 12),

                  // 🔍 Animated Search Bar (flexible space between logo and buttons)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSearching
                          ? TextField(
                        key: const ValueKey("searchField"),
                        controller: _searchController,
                        onChanged: (query) {
                          searchQuery = query;
                          searchListings(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                          : const SizedBox.shrink(), // empty space when not searching
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 🔍 Search Icon (toggle)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          searchQuery = '';
                          fetchListings(); // Reset results
                        }
                      });
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.red),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 🛠 Filter Icon
                  GestureDetector(
                    onTap: () {
                      // Open your filter dialog
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),



            // 📂 Category Filter Chips
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
                      selectedColor: Colors.red,
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

            // 🏡 Listings Carousel + 🎉 Student Offers
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Hot Deals Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: Text(
                        "🌟 Hot Deals For You",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: listings.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: listings.length,
                        itemBuilder: (_, index) {
                          final item = listings[index];
                          final List<String> imageUrls = List<String>.from(item['image_url'] ?? []);
                          final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailPage(listingId: item['id']),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              margin: const EdgeInsets.only(right: 16),
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
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      imageUrl,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 160,
                                        color: Colors.grey[300],
                                        child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatCurrency.format(item['price']),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['address'] ?? '',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🎓 Student Banners
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🎉 Special for Students!",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Banner 1
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purpleAccent, Colors.deepPurple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Get ₹1000 Off on Your First PG Booking!",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Limited time offer • T&C apply",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Banner 2
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orangeAccent, Colors.deepOrange],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Now available near top colleges in Mumbai!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 📱 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
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
            const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add Listing"),
          const BottomNavigationBarItem(icon: Icon(Icons.timeline), label: "Activity"),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );

  }
}
