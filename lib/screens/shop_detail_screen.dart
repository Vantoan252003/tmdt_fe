import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shop.dart';
import '../models/shop_review.dart';
import '../services/shop_service.dart';
import '../services/shop_review_service.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../widgets/product_card.dart';
import '../utils/app_theme.dart';
import 'chat_screen.dart';

const shopeeColor = Color(0xFFFF5722);

class ShopDetailScreen extends StatefulWidget {
  final String shopId;
  final String? shopName;

  const ShopDetailScreen({
    super.key,
    required this.shopId,
    this.shopName,
  });

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  final ShopService _shopService = ShopService();
  final ShopReviewService _reviewService = ShopReviewService();

  Shop? _shop;
  bool _isLoading = false;
  bool _isLoadingReviews = false;

  late TabController _tabController;
  List<ShopReview> _reviews = [];
  CanReviewShopResponse? _canReview;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _loadShopDetails();
    _loadShopReviews();
    _checkCanReview();
  }

  Future<void> _loadShopDetails() async {
    setState(() => _isLoading = true);

    try {
      final shop = await _shopService.getShopDetails(widget.shopId);
      if (mounted) {
        setState(() {
          _shop = shop;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadShopReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final data = await _reviewService.getShopReviews(widget.shopId);
      if (mounted) {
        setState(() {
          _reviews = data;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _checkCanReview() async {
    try {
      final result = await _reviewService.canReviewShop(widget.shopId);
      if (mounted) setState(() => _canReview = result);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGradient.colors.first,
      appBar: AppBar(
        backgroundColor: shopeeColor,
        elevation: 0,
        title: Text(
          _shop?.shopName ?? "Cửa hàng",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: shopeeColor))
          : _shop == null
              ? const Center(child: Text("Không tìm thấy cửa hàng"))
              : Column(
                  children: [
                    _buildShopHeader(),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(),
                          _buildProductsTab(),
                          _buildReviewsTab(),
                          _buildInfoTab(),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }

  // ------------------------
  // SHOP HEADER FIXED
  // ------------------------
  Widget _buildShopHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // SHOP AVATAR
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _shop?.logoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: _shop!.logoUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.store, size: 40),
                      ),
              ),

              const SizedBox(width: 16),

              // SHOP NAME + RATING
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shop?.shopName ?? 'Cửa hàng',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: shopeeColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          (_shop?.rating ?? 0).toStringAsFixed(1),
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "${_shop?.totalProducts ?? 0} sản phẩm",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // CHAT BUTTON
              InkWell(
                onTap: _startChat,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: shopeeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat, color: shopeeColor),
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          // FOLLOW + CHAT
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: shopeeColor),
                  ),
                  child:
                      const Text("Theo dõi", style: TextStyle(color: shopeeColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _startChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: shopeeColor,
                  ),
                  child: const Text("Chat ngay",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ------------------------
  // TAB BAR
  // ------------------------
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: shopeeColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: shopeeColor,
        tabs: const [
          Tab(icon: Icon(Icons.storefront), text: "Gian hàng"),
          Tab(icon: Icon(Icons.inventory), text: "Sản phẩm"),
          Tab(icon: Icon(Icons.star), text: "Đánh giá"),
          Tab(icon: Icon(Icons.info_outline), text: "Thông tin"),
        ],
      ),
    );
  }

  // ------------------------
  // TAB 1 — GIAN HÀNG
  // ------------------------
  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_shop!.description.isNotEmpty)
          _buildCard(
            child: Text(_shop!.description,
                style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        const SizedBox(height: 20),

        const Text("Sản phẩm nổi bật",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _shop!.products.length > 4 ? 4 : _shop!.products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) => ProductCard(product: _shop!.products[i]),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  // ------------------------
  // TAB 2 — PRODUCTS
  // ------------------------
  Widget _buildProductsTab() {
    if (_shop!.products.isEmpty) {
      return const Center(child: Text("Không có sản phẩm"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _shop!.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => ProductCard(product: _shop!.products[i]),
    );
  }

  // ------------------------
  // TAB 3 — REVIEWS
  // ------------------------
  Widget _buildReviewsTab() {
    return _isLoadingReviews
        ? const Center(child: CircularProgressIndicator(color: shopeeColor))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reviews.length,
            itemBuilder: (_, i) => _buildReviewCard(_reviews[i]),
          );
  }

  Widget _buildReviewCard(ShopReview r) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: shopeeColor.withOpacity(0.2),
              child: Text(
                r.userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: shopeeColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < r.rating ? Icons.star : Icons.star_border,
                color: shopeeColor,
                size: 18,
              ),
            ),
          ),
          if (r.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(r.comment),
          ]
        ],
      ),
    );
  }

  // ------------------------
  // TAB 4 — INFO
  // ------------------------
  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(child: Text("Địa chỉ: ${_shop!.address}")),
        const SizedBox(height: 16),
        _buildCard(child: Text("Số điện thoại: ${_shop!.phoneNumber}")),
        const SizedBox(height: 16),
        _buildCard(child: Text("Ngày tạo: ${_shop!.createdAt}")),
      ],
    );
  }

  // ------------------------
  // CHAT START
  // ------------------------
  Future<void> _startChat() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final chat = await ChatService().startConversation(widget.shopId);

      if (mounted && chat != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: chat.conversationId,
              otherUserId: widget.shopId,
              otherUserName: _shop?.shopName ?? "",
              otherUserAvatar: _shop?.logoUrl,
            ),
          ),
        );
      }
    } catch (_) {}
  }
}
