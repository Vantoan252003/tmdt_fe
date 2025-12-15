import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/review_service.dart';
import '../utils/app_theme.dart';

class AddReviewDialog extends StatefulWidget {
  final String productId;
  final VoidCallback onReviewSubmitted;

  const AddReviewDialog({
    super.key,
    required this.productId,
    required this.onReviewSubmitted,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  int _rating = 5;
  List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _canReview = false;
  String _reviewStatus = '';

  @override
  void initState() {
    super.initState();
    _checkReviewEligibility();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkReviewEligibility() async {
    try {
      final canReview = await _reviewService.canReviewProduct(widget.productId);
      
      if (mounted) {
        setState(() {
          _canReview = canReview['canReview'] ?? false;
          if (canReview['hasReviewed'] == true) {
            _reviewStatus = 'Bạn đã đánh giá sản phẩm này rồi';
          } else if (canReview['hasPurchased'] == false) {
            _reviewStatus = 'Bạn cần mua sản phẩm này trước khi đánh giá';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewStatus = 'Lỗi kiểm tra quyền đánh giá';
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
        widget.productId,
        _rating,
        _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onReviewSubmitted();
        if (Navigator.canPop(context)) Navigator.pop(context);
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Viết đánh giá',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_canReview && _reviewStatus.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[700], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _reviewStatus,
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_canReview) ...[
                    // Rating selector
                    const Text(
                      'Đánh giá sao',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
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
                                ? AppTheme.ratingColor
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Comment
                    const Text(
                      'Nhận xét (tùy chọn)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Chia sẻ trải nghiệm của bạn với sản phẩm này...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Images
                    const Text(
                      'Hình ảnh (tối đa 3)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        ...List.generate(
                          _selectedImages.length,
                          (index) => Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
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
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppTheme.primaryColor,
                                  size: 32,
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
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
