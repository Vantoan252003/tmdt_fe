# Quick Start: Review Feature

## What Was Implemented

Your product review feature is now fully implemented with:

✅ **Review Models** - Complete data structures
✅ **Review Service** - All 6 API methods ready
✅ **Review Screen** - Full review display & submission UI
✅ **Product Integration** - Review button on product detail screen
✅ **Image Upload** - Support for up to 3 images per review
✅ **Authentication** - Secure review creation with bearer tokens
✅ **Purchase Verification** - Prevents non-buyers from reviewing

## How to Use

### For End Users
1. View a product → Click "Xem đánh giá" button
2. In Review Screen:
   - See existing reviews with images and ratings
   - See rating statistics (average, total, distribution)
   - If eligible (purchased product):
     - Select rating (1-5 stars)
     - Add optional comment
     - Upload up to 3 images
     - Submit review
   - If not eligible: See informative message

### For Developers

#### Get Product Reviews
```dart
final reviewService = ReviewService();
final reviews = await reviewService.getProductReviews(productId);
```

#### Get Rating Stats
```dart
final stats = await reviewService.getProductRatingStats(productId);
print('Average: ${stats.averageRating}');
print('Total Reviews: ${stats.totalReviews}');
```

#### Check if User Can Review
```dart
final canReview = await reviewService.canReviewProduct(productId);
if (canReview['canReview']) {
  // Show review form
} else if (!canReview['hasPurchased']) {
  // Show "Must purchase first" message
} else if (canReview['hasReviewed']) {
  // Show "Already reviewed" message
}
```

#### Submit Review
```dart
try {
  final review = await reviewService.createReview(
    productId: '123',
    rating: 5,
    comment: 'Great product!',
    images: [File('/path/to/image.jpg')], // optional, max 3
  );
  print('Review created: ${review.id}');
} catch (e) {
  print('Error: $e');
}
```

## File Structure

```
lib/
├── models/
│   └── review.dart                 ← Review, ReviewResponse, RatingStats
├── services/
│   └── review_service.dart         ← API methods (6 functions)
└── screens/
    ├── review_screen.dart          ← Full review UI
    └── product_detail_screen.dart  ← Updated with review button
```

## Dependencies
- `image_picker: ^1.0.0` (added to pubspec.yaml)

Run `flutter pub get` to install.

## API Endpoints Used

All these endpoints are called automatically by ReviewService:

```
POST   /api/reviews/create                         (multipart)
GET    /api/reviews/product/{productId}
GET    /api/reviews/product/{productId}/stats
GET    /api/reviews/my-reviews                      (auth)
GET    /api/reviews/reviewable-products             (auth)
GET    /api/reviews/can-review?productId=...        (auth)
```

## Key Implementation Details

### ReviewScreen Features
- Product info card at top
- Aggregated rating statistics
- Review form with:
  - 5-star interactive selector
  - Text comment input (optional)
  - Image picker grid (max 3)
  - Submit button
- Existing reviews list with:
  - Reviewer name
  - Star rating
  - Comment text
  - Image thumbnails (scrollable)
  - Timestamp

### Smart Features
- **Prevents invalid submissions** (rating required)
- **Limits to 3 images** with validation
- **Purchase verification** before showing form
- **Prevents duplicate reviews** (checks hasReviewed)
- **Beautiful error messages** (informative, not technical)
- **Loading states** throughout
- **Form reset** after successful submission
- **Auto-reload** reviews after posting

## Customization

### Change star color
Edit in `lib/utils/app_theme.dart`:
```dart
static const Color ratingColor = Color(0xFFFBBF24); // Change this
```

### Change review button appearance
Edit in `lib/screens/product_detail_screen.dart` (_buildBottomBar method):
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: Colors.orange[100],
  foregroundColor: Colors.orange[700],
  // customize colors here
),
```

### Change image picker limits
Edit in `lib/screens/review_screen.dart` (_pickImages method):
```dart
if (_selectedImages.length + newImages.length > 3) { // change 3 to any number
  // error shown
}
```

## Troubleshooting

### Images not uploading
- Check `image_picker` is installed: `flutter pub get`
- Verify file permissions in Android/iOS
- Check multipart request headers

### "Cannot review" message showing
- Verify user has purchased product (check backend)
- Verify user is authenticated (Bearer token present)

### Reviews not loading
- Check network connectivity
- Verify API endpoint is correct in ApiEndpoints
- Check AuthService provides valid token

## Testing Locally

### Mock data for testing
```dart
// In ReviewScreen or test widget
final mockReviews = [
  ReviewResponse(
    id: '1',
    productId: 'prod123',
    rating: 5,
    comment: 'Excellent!',
    userName: 'John Doe',
    createdAt: '2024-01-20',
    imageUrls: ['https://example.com/img.jpg'],
  ),
];
```

## Next Phase (Optional)

After testing, consider:
1. User profile page showing their reviews
2. Edit/delete own reviews
3. Review sorting options
4. Helpful/unhelpful voting
5. Review moderation for shop owner

## Questions?

Refer to `REVIEW_FEATURE_GUIDE.md` for detailed API documentation.
