# Review Feature Implementation Guide

## Overview
Comprehensive product review system with image upload support, rating validation, and purchase verification.

## Files Created/Modified

### 1. **Models** (`lib/models/`)
#### `review.dart` ⭐ NEW
- **Review**: Main review entity with id, productId, userId, userName, rating, comment, imageUrls, createdAt
- **ReviewResponse**: API response model with parsed data
- **CreateReviewRequest**: Request body for creating reviews
- **RatingStats**: Statistics for product ratings (averageRating, totalReviews, ratingCounts)

### 2. **Services** (`lib/services/`)
#### `review_service.dart` ⭐ NEW
Six main API integration methods:

1. **createReview(productId, rating, comment, images)**
   - Method: `POST /api/reviews/create`
   - Multipart form-data with file uploads (max 3 images)
   - Requires Bearer token authentication
   - Returns: Review object

2. **getProductReviews(productId)**
   - Method: `GET /api/reviews/product/{productId}`
   - Public endpoint (no auth required)
   - Returns: List<ReviewResponse>

3. **getProductRatingStats(productId)**
   - Method: `GET /api/reviews/product/{productId}/stats`
   - Public endpoint
   - Returns: RatingStats with averageRating, totalReviews, ratingCounts

4. **getMyReviews()**
   - Method: `GET /api/reviews/my-reviews`
   - Requires authentication
   - Returns: List<ReviewResponse> of user's reviews

5. **getReviewableProducts()**
   - Method: `GET /api/reviews/reviewable-products`
   - Requires authentication
   - Returns: List<Product> user can review

6. **canReviewProduct(productId)**
   - Method: `GET /api/reviews/can-review?productId={productId}`
   - Requires authentication
   - Returns: {canReview: bool, hasPurchased: bool, hasReviewed: bool}

### 3. **Screens** (`lib/screens/`)
#### `review_screen.dart` ⭐ NEW
Complete review management screen with:

- **Review Display**
  - Product info card (image, name, price)
  - Overall rating statistics
  - List of existing reviews with images

- **Review Form** (if user can review)
  - Star rating selector (1-5)
  - Text comment input (optional)
  - Image picker (max 3 images)
  - Submit button with loading state

- **Review Items**
  - Reviewer name, rating, comment
  - Image gallery (scrollable)
  - Timestamp

- **Status Messages**
  - Shows if user already reviewed
  - Shows if user hasn't purchased
  - Loading and error states

#### `product_detail_screen.dart` (Modified)
- Added "Xem đánh giá" button in bottom bar
- Routes to ReviewScreen with product data
- Maintains add-to-cart functionality

## Key Features

### ✅ Purchase Verification
- `canReviewProduct()` checks if user has purchased product
- Prevents reviewing products user hasn't purchased
- Displays appropriate status message

### ✅ Image Upload
- Supports up to 3 images per review
- Uses `image_picker` package
- Multipart form-data submission
- Image preview in review form and display

### ✅ Rating System
- 5-star rating selector (interactive)
- Average rating display
- Total review count
- Rating distribution stats (ratingCounts)

### ✅ Authentication
- Bearer token authentication for user operations
- Public access to view reviews
- Secure review creation

### ✅ User Experience
- Real-time image preview
- Loading indicators
- Error handling with user-friendly messages
- Success notifications
- Form reset after submission

## Dependencies Added
- `image_picker: ^1.0.0` - Image selection from device

## API Integration Points

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/reviews/create` | POST | Yes | Create review with images |
| `/api/reviews/product/{id}` | GET | No | Get product reviews |
| `/api/reviews/product/{id}/stats` | GET | No | Get rating statistics |
| `/api/reviews/my-reviews` | GET | Yes | Get user's reviews |
| `/api/reviews/reviewable-products` | GET | Yes | List products user can review |
| `/api/reviews/can-review` | GET | Yes | Check review eligibility |

## Usage Flow

### 1. View Product
```
ProductDetailScreen
  ├─ Display product info
  └─ "Xem đánh giá" button → ReviewScreen
```

### 2. In ReviewScreen
```
ReviewScreen
  ├─ Load product reviews
  ├─ Load rating stats
  ├─ Check canReviewProduct()
  ├─ If can review:
  │  ├─ Show review form
  │  ├─ Select rating + add comment
  │  ├─ Pick images (optional)
  │  └─ Submit review
  └─ Display existing reviews
```

### 3. Form Submission
```
ReviewScreen._submitReview()
  ├─ Validate rating (required)
  ├─ Call reviewService.createReview()
  ├─ Show success message
  ├─ Clear form
  └─ Reload review data
```

## Error Handling
- Network errors with user-friendly messages
- Image selection errors
- Authentication errors
- API response errors

## Next Steps (Optional Enhancements)

1. **User Profile Reviews**
   - Display user's reviews in profile screen
   - Edit/delete own reviews
   - Review management interface

2. **Review Sorting**
   - Sort by recent, helpful, rating
   - Filter by rating

3. **Review Analytics**
   - Most helpful reviews
   - Verified purchase badges
   - Review moderation

4. **Image Gallery**
   - Full-screen image viewer
   - Zoom functionality
   - Download option

## Testing Checklist

- [ ] View reviews for a product
- [ ] View rating statistics
- [ ] Check purchase requirement validation
- [ ] Submit review with comment only
- [ ] Submit review with images (1, 2, 3)
- [ ] Cannot submit without rating
- [ ] Cannot exceed 3 images
- [ ] Cannot review twice
- [ ] Images load in review list
- [ ] Error handling works
- [ ] Success notification shows

## Notes
- Maximum 3 images per review
- Comment is optional
- Rating is required (1-5 stars)
- Users must have purchased to review
- Users cannot review twice
- Images are compressed at 80% quality
