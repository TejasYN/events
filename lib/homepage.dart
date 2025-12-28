import 'package:flutter/material.dart';
import 'category.dart';
import 'favorites.dart';
import 'cart.dart';
import 'profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB8860B), // Gold color
      ),
      home: const HomePage(),
    );
  }
}

Widget _venueCard(String imagePath, String title) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Stack(
      children: [
        Image.asset(
          imagePath,
          width: 200,
          height: 125,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            color: Colors.black.withOpacity(0.5), // Semi-transparent black
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchIcon = false;

  void _handleScroll() {
    if (_scrollController.offset > 120 && !_showSearchIcon) {
      setState(() => _showSearchIcon = true);
    } else if (_scrollController.offset <= 120 && _showSearchIcon) {
      setState(() => _showSearchIcon = false);
    }
  }

  // Banner scroll/animation controllers
  late final PageController _pageController;
  int _currentPage = 0;
  late final AnimationController _bannerController;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;
  late final Animation<Offset> _imageSlide;
  late final Animation<double> _imageFade;
  late final PageController _curvedImageController;
  int _curvedImagePage = 0;
  late final List<String> _curvedImages;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    _curvedImages = [
      'assets/images/wedding2.jpg',
      'assets/images/retirement.jpg',
      'assets/images/bday2.jpg',
    ];
    _curvedImageController = PageController(initialPage: 0);

    _pageController = PageController(initialPage: 0);
    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(-0.25, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bannerController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _bannerController,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
    );
    _imageSlide = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bannerController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _imageFade = CurvedAnimation(
      parent: _bannerController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
    _startBannerAnimation();
    _startAutoScroll();
    _startCurvedImageAutoScroll();
  }

  void _startBannerAnimation() {
    _bannerController.forward(from: 0);
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 15));
      final next = (_currentPage + 1) % 2;
      await _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600), 
        curve: Curves.easeInOut,
      );
      if (!mounted) return;
      _startBannerAnimation();
    }
  }

  void _startCurvedImageAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 10));
      final next = (_curvedImagePage + 1) % _curvedImages.length;
      await _curvedImageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      if (!mounted) return;
      _curvedImagePage = next;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _bannerController.dispose();
    _curvedImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(70),
  child: Container(
    padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1), // Transparent with slight tint
      // Add subtle blur effect (iOS-style)
      backgroundBlendMode: BlendMode.overlay,
    ),
    child: SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "EventsPal",
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 36,
              color: Colors.black, // Gold
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 0),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 100),
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: Icon(Icons.notifications_none, color: Colors.grey[800]),
          ),
          
          
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: Icon(Icons.person, color: Colors.grey[800]),
              ),
            ),


        ],
      ),
    ),
  ),
),

      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scrollable Animated Banner
                SizedBox(
                  height: 240,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _currentPage = index;
                      _startBannerAnimation();
                    },
                    children: [
                      buildBanner(
                        title: 'Wedding Essentials',
                        buttonText: 'Shop Now',
                        imagePath: 'assets/images/bride_groom.png',
                      ),
                      buildBanner(
                        title: 'Birthday Essentials',
                        buttonText: 'Shop Now',
                        imagePath: 'assets/images/bday.png',
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      categoryItem(Icons.apartment, "Venue"),
                      categoryItem(Icons.restaurant, "Catering"),
                      categoryItem(Icons.camera_alt, "Photos"),
                      categoryItem(Icons.chair, "Decors"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

// Events
sectionTitle("Events"),
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      const SizedBox(width: 16),
      _venueCard('assets/images/wedding.jpg', 'Wedding'),
      const SizedBox(width: 10),
      _venueCard('assets/images/birthday.jpg', 'Birthday'),
      const SizedBox(width: 10),
      _venueCard('assets/images/prewedding.jpg', 'Pre-Wedding'),
      const SizedBox(width: 10),
      _venueCard('assets/images/photoshoots.jpg', 'Photoshoots'),
      const SizedBox(width: 10),
      _venueCard('assets/images/housewarming.jpg', 'Housewarming'),
      const SizedBox(width: 10),
      _venueCard('assets/images/namingceremony.jpg', 'Naming Ceremony'),
      const SizedBox(width: 10),
      _venueCard('assets/images/bachelorparty.jpg', 'Bachelor Party'),
      const SizedBox(width: 10),
      _venueCard('assets/images/retirementparty.jpg', 'Retirement Party'),
      const SizedBox(width: 10),
      _venueCard('assets/images/graduationparty.jpg', 'Graduation Party'),
      const SizedBox(width: 10),
      _venueCard('assets/images/gettogether.jpg', 'Get-Together'),
      const SizedBox(width: 10),
      _venueCard('assets/images/afterparty.jpg', 'After Party'),
      const SizedBox(width: 10),
      _venueCard('assets/images/successparty.jpg', 'Success Party'),
    ],
  ),
),
const SizedBox(height: 24),

                // Near You
                sectionTitle("Near You"),
                _venueRow(['assets/images/venue4.jpeg', 'assets/images/venue3.jpeg']),
                const SizedBox(height: 32),
SizedBox(
  height: 200,
  child: PageView.builder(
    controller: _curvedImageController,
    itemCount: _curvedImages.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _curvedImage(_curvedImages[index]),
      );
    },
    onPageChanged: (index) {
      _curvedImagePage = index;
    },
  ),
),
const SizedBox(height: 24),
                // Recommended
                sectionTitle("Recommended For You"),
                _venueRow(['assets/images/venue2.jpeg', 'assets/images/venue5.jpeg']),
                const SizedBox(height: 24),
                _venueRow(['assets/images/venue6.jpeg', 'assets/images/venue3.jpeg']),
              ],
            ),
          ),

          // Animated Floating Search Icon
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            left: 0,
            right: 0,
            bottom: _showSearchIcon ? 32 : -12, // Pops up from behind the nav bar
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showSearchIcon ? 1.0 : 0.0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.search, color: Color(0xFF8B0000), size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16), // Adjust value as needed
        child: const CurvedBottomNav(),
      ),
    );
  }

  // Animated buildBanner widget
  Widget buildBanner({
    required String title,
    required String buttonText,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          FadeTransition(
            opacity: _imageFade,
            child: SlideTransition(
              position: _imageSlide,
              child: SizedBox(
                height: 160,
                width: 160,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 160, width: 160, color: Colors.grey[300]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget categoryItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700)),
          ),
          padding: const EdgeInsets.all(20),
          child: Icon(icon, size: 32, color: const Color(0xFF8B0000)),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  static Widget _venueRow(List<String> paths) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _safeImage(paths[0])),
          const SizedBox(width: 12),
          Expanded(child: _safeImage(paths[1])),
        ],
      ),
    );
  }

  static Widget _safeImage(String path, {double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        path,
        height: height ?? 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(height: height ?? 120, color: Colors.grey[300]),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  static Widget _curvedImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        path,
        width: 380,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(width: 380, height: 200, color: Colors.grey[300]),
      ),
    );
  }
}

class CurvedBottomNav extends StatefulWidget {
  const CurvedBottomNav({super.key});

  @override
  State<CurvedBottomNav> createState() => _CurvedBottomNavState();
}

class _CurvedBottomNavState extends State<CurvedBottomNav> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CategoriesScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Favorites()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );
    }
    // index 0 is home, do nothing
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8B0000),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
        ],
      ),
    );
  }
}