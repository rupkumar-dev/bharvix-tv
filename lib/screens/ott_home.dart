import 'package:bharvix_tv/core/app_colors.dart';
import 'package:bharvix_tv/models/app_channel.dart';
import 'package:bharvix_tv/provider/iptv_provider.dart';
import 'package:bharvix_tv/screens/VideoPlayer/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


// ==================== OTT HOME SCREEN ====================

class OTTHomeScreen extends StatefulWidget {
  const OTTHomeScreen({super.key});

  @override
  State<OTTHomeScreen> createState() => _OTTHomeScreenState();
}

class _OTTHomeScreenState extends State<OTTHomeScreen> {
  final ScrollController _mainScrollController = ScrollController();
  int _selectedCategoryIndex = 0;
  int _selectedItemIndex = 0;
  final List<GlobalKey> _categoryKeys = [];

  // Category definitions
  final List<CategoryData> categories = [
    CategoryData(title: '🔥 Popular', type: CategoryType.popular, icon: Icons.local_fire_department),
    CategoryData(title: '📈 Trending Now', type: CategoryType.trending, icon: Icons.trending_up),
    CategoryData(title: '⭐ Top Rated', type: CategoryType.topRated, icon: Icons.star),
    CategoryData(title: '🎬 Movies', type: CategoryType.movies, icon: Icons.movie),
    CategoryData(title: '⚽ Sports', type: CategoryType.sports, icon: Icons.sports_soccer),
    CategoryData(title: '📰 News', type: CategoryType.news, icon: Icons.newspaper),
    CategoryData(title: '😂 Comedy', type: CategoryType.comedy, icon: Icons.sentiment_very_satisfied),
    CategoryData(title: '🎭 Drama', type: CategoryType.drama, icon: Icons.theater_comedy),
    CategoryData(title: '🇮🇳 India Hindi', type: CategoryType.indiaHindi, icon: Icons.flag),
    CategoryData(title: '💡 Recommended', type: CategoryType.recommended, icon: Icons.recommend),
    CategoryData(title: '🕐 Recently Added', type: CategoryType.recent, icon: Icons.schedule),
    CategoryData(title: '🏆 Top 10 Today', type: CategoryType.top10, icon: Icons.emoji_events),
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < categories.length; i++) {
      _categoryKeys.add(GlobalKey());
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  List<AppChannel> _getChannelsForCategory(IptvProvider provider, CategoryType type) {
    switch (type) {
      case CategoryType.popular:
        return provider.popularChannels();
      case CategoryType.trending:
        return provider.channels.take(20).toList();
      case CategoryType.topRated:
        return provider.popularChannels().take(15).toList();
      case CategoryType.movies:
        return provider.filterChannels(category: 'movies');
      case CategoryType.sports:
        return provider.filterChannels(category: 'sports');
      case CategoryType.news:
        return provider.filterChannels(category: 'news');
      case CategoryType.comedy:
        return provider.filterChannels(category: 'comedy');
      case CategoryType.drama:
        return provider.filterChannels(category: 'drama');
      case CategoryType.indiaHindi:
        return provider.filterChannels(country: 'IN', language: 'hin');
      case CategoryType.recommended:
        return provider.channels.skip(10).take(20).toList();
      case CategoryType.recent:
        return provider.channels.reversed.take(20).toList();
      case CategoryType.top10:
        return provider.popularChannels().take(10).toList();
      case CategoryType.all:
        return provider.channels.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();

    if (provider.loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Loading channels...',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
          // Gradient App Bar
          _buildAppBar(),

          // Featured Hero Banner
          SliverToBoxAdapter(
            child: FeaturedHeroBanner(
              channels: provider.popularChannels(),
            ),
          ),

          // Quick Category Chips
          SliverToBoxAdapter(
            child: _buildQuickCategories(),
          ),

          // Category Rows
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final channels = _getChannelsForCategory(provider, category.type);

            if (channels.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverToBoxAdapter(
              key: _categoryKeys[index],
              child: CategoryRowSection(
                title: category.title,
                icon: category.icon,
                channels: channels,
                isTop10: category.type == CategoryType.top10,
                categoryIndex: index,
              ),
            );
          }),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 60,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          title: Row(
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'BHARVIX',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Spacer(),
              // Navigation Items
              _buildNavItem('Home', true),
              _buildNavItem('TV Shows', false),
              _buildNavItem('Movies', false),
              _buildNavItem('Sports', false),
              _buildNavItem('My List', false),
              const SizedBox(width: 20),
              // Search & Profile
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildQuickCategories() {
    final quickCategories = ['All', 'Action', 'Comedy', 'Drama', 'Horror', 'Romance', 'Sci-Fi'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: quickCategories.map((cat) {
            final isSelected = cat == 'All';
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) {},
                backgroundColor: Colors.grey[900],
                selectedColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.white : Colors.grey[700]!,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ==================== CATEGORY DATA ====================

enum CategoryType {
  popular,
  trending,
  topRated,
  movies,
  sports,
  news,
  comedy,
  drama,
  indiaHindi,
  recommended,
  recent,
  top10,
  all,
}

class CategoryData {
  final String title;
  final CategoryType type;
  final IconData icon;

  CategoryData({
    required this.title,
    required this.type,
    required this.icon,
  });
}

// ==================== FEATURED HERO BANNER ====================

class FeaturedHeroBanner extends StatefulWidget {
  final List<AppChannel> channels;

  const FeaturedHeroBanner({super.key, required this.channels});

  @override
  State<FeaturedHeroBanner> createState() => _FeaturedHeroBannerState();
}

class _FeaturedHeroBannerState extends State<FeaturedHeroBanner> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && widget.channels.isNotEmpty) {
        final nextPage = (_currentPage + 1) % widget.channels.take(5).length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.channels.isEmpty) return const SizedBox.shrink();

    final featuredChannels = widget.channels.take(5).toList();

    return Column(
      children: [
        SizedBox(
          height: 450,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: featuredChannels.length,
            itemBuilder: (context, index) {
              final channel = featuredChannels[index];
              return _HeroBannerCard(channel: channel, index: index);
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            featuredChannels.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 4,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.red : Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _HeroBannerCard extends StatelessWidget {
  final AppChannel channel;
  final int index;

  const _HeroBannerCard({required this.channel, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            channel.logo.isNotEmpty
                ? Image.network(
                    channel.logo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),

            // Gradient Overlays
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Left Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 40,
              bottom: 40,
              right: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    channel.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta Info
                  Row(
                    children: [
                      _buildMetaChip('HD'),
                      const SizedBox(width: 8),
                      _buildMetaChip('LIVE'),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      // Play Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerScreen(channel: channel),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: const Text(
                          'Play Now',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info Button
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.info_outline),
                        label: const Text('More Info'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add to List
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[800]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.tv, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildMetaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ==================== CATEGORY ROW SECTION ====================

class CategoryRowSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<AppChannel> channels;
  final bool isTop10;
  final int categoryIndex;

  const CategoryRowSection({
    super.key,
    required this.title,
    required this.icon,
    required this.channels,
    this.isTop10 = false,
    required this.categoryIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal List
        SizedBox(
          height: isTop10 ? 200 : 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: isTop10
                    ? Top10ChannelCard(
                        channel: channels[index],
                        rank: index + 1,
                      )
                    : OTTChannelCard(
                        channel: channels[index],
                        categoryIndex: categoryIndex,
                        itemIndex: index,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== OTT CHANNEL CARD ====================

class OTTChannelCard extends StatefulWidget {
  final AppChannel channel;
  final int categoryIndex;
  final int itemIndex;

  const OTTChannelCard({
    super.key,
    required this.channel,
    required this.categoryIndex,
    required this.itemIndex,
  });

  @override
  State<OTTChannelCard> createState() => _OTTChannelCardState();
}

class _OTTChannelCardState extends State<OTTChannelCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFocused = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: _onFocusChange,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.select) {
          _navigateToPlayer();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          if (!_isFocused) _controller.reverse();
        },
        child: GestureDetector(
          onTap: _navigateToPlayer,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: (_isHovered || _isFocused)
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Image
                    Positioned.fill(
                      child: widget.channel.logo.isNotEmpty
                          ? Image.network(
                              widget.channel.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Live Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 6),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Title
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Text(
                        widget.channel.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),

                    // Hover Overlay
                    if (_isHovered || _isFocused)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[850]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.tv, color: Colors.white24, size: 40),
      ),
    );
  }

  void _navigateToPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(channel: widget.channel),
      ),
    );
  }
}

// ==================== TOP 10 CHANNEL CARD ====================

class Top10ChannelCard extends StatefulWidget {
  final AppChannel channel;
  final int rank;

  const Top10ChannelCard({
    super.key,
    required this.channel,
    required this.rank,
  });

  @override
  State<Top10ChannelCard> createState() => _Top10ChannelCardState();
}

class _Top10ChannelCardState extends State<Top10ChannelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(channel: widget.channel),
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 180,
            child: Row(
              children: [
                // Rank Number
                Text(
                  '${widget.rank}',
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.grey[600]!,
                  ),
                ),

                // Card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: -30),
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          widget.channel.logo.isNotEmpty
                              ? Image.network(
                                  widget.channel.logo,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.tv, color: Colors.white54),
                                ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Text(
                              widget.channel.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_isHovered)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ANIMATED BUILDER HELPER ====================

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}