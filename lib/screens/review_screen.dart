import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/review.dart';
import '../services/review_service.dart';
import '../utils/app_theme.dart';
import '../models/product.dart';

class ReviewScreen extends StatefulWidget {
  final Product product;

  const ReviewScreen({
    super.key,
    required this.product,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int _rating = 5;
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _canReview = false;
  String _reviewStatus = '';
  List<ReviewResponse> _reviews = [];
  RatingStats? _ratingStats;

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviewData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user can review
      final canReview = await _reviewService.canReviewProduct(widget.product.productId);
      
      // Get product reviews
      final reviews = await _reviewService.getProductReviews(widget.product.productId);
      
      // Get rating stats
      final stats = await _reviewService.getProductRatingStats(widget.product.productId);

      if (mounted) {
        setState(() {
          _canReview = canReview['canReview'] ?? false;
          if (canReview['hasReviewed'] == true) {
            _reviewStatus = 'Bạn đã đánh giá sản phẩm này rồi';
          } else if (canReview['hasPurchased'] == false) {
            _reviewStatus = 'Bạn cần mua sản phẩm này trước khi đánh giá';
          }
          _reviews = reviews;
          _ratingStats = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        final newImages = pickedFiles.map((file) => File(file.path)).toList();
        
        // Max 3 images
        if (_selectedImages.length + newImages.length > 3) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chỉ được chọn tối đa 3 hình ảnh')),
            );
          }
          return;
        }

        setState(() {
          _selectedImages.addAll(newImages);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
      }
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đánh giá sao')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _reviewService.createReview(
        widget.product.productId,
        _rating,
        _commentController.text.trim().isNotEmpty ? _commentController.text.trim() : null,
        _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _commentController.clear();
        setState(() {
          _selectedImages.clear();
          _rating = 5;
        });

        // Reload data
        await _loadReviewData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Đánh giá sản phẩm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE4D2D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE4D2D)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Product info card
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          child: widget.product.mainImageUrl != null
                              ? Image.network(
                                  widget.product.mainImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported);
                                  },
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.productName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.product.price.toStringAsFixed(0)}₫',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEE4D2D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),


                  // Rating stats
                  if (_ratingStats != null)
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đánh giá chung',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _ratingStats!.averageRating
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFEE4D2D),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              ...List.generate(
                                                5,
                                                (index) => Icon(
                                                  Icons.star,
                                                  size: 18,
                                                  color: index <
                                                          _ratingStats!.averageRating
                                                              .toInt()
                                                      ? const Color(0xFFFBBF24)
                                                      : Colors.grey[300],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_ratingStats!.totalReviews} đánh giá',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Create review form
                  if (_canReview)
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Viết đánh giá của bạn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Rating selector
                          const Text(
                            'Đánh giá sao',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(
                              5,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rating = index + 1;
                                  });
                                },
                                child: Icon(
                                  Icons.star,
                                  size: 40,
                                  color: index < _rating
                                      ? const Color(0xFFFBBF24)
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Comment
                          const Text(
                            'Nhận xét',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commentController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Chia sẻ trải nghiệm của bạn với sản phẩm này...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEE4D2D),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Images
                          const Text(
                            'Hình ảnh (tối đa 3)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              ...List.generate(
                                _selectedImages.length,
                                (index) => Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: FileImage(_selectedImages[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEE4D2D),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedImages.length < 3)
                                GestureDetector(
                                  onTap: _pickImages,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[50],
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: Color(0xFFEE4D2D),
                                            size: 32,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Thêm ảnh',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFEE4D2D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEE4D2D),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: Colors.grey[400],
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Gửi đánh giá',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_reviewStatus.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[700], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _reviewStatus,
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Reviews list
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Các đánh giá khác',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_reviews.isEmpty)
                          Center(
                            child: Text(
                              'Chưa có đánh giá nào',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reviews.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[200],
                              height: 16,
                            ),
                            itemBuilder: (context, index) {
                              final review = _reviews[index];
                              return _buildReviewItem(review);
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }

  Widget _buildReviewItem(ReviewResponse review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 16,
                        color: index < review.rating
                            ? const Color(0xFFFBBF24)
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              review.createdAt,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Comment
        if (review.comment != null && review.comment!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
          ),

        // Images
        if (review.images != null && review.images!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(review.images![index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
