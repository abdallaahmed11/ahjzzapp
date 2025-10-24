import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/rate_service_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
// import 'package:ahjizzzapp/services/db_service.dart'; // To provide DbService if needed

// Function to show the modal
void showRateServiceModal(BuildContext context, String bookingId, String providerName) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the modal to take up more height
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      // Provide the ViewModel specifically for this modal instance
      return ChangeNotifierProvider(
        // create: (ctx) => RateServiceViewModel(ctx.read<DbService>(), bookingId, providerName), // Future
        create: (ctx) => RateServiceViewModel(bookingId, providerName), // Temporary
        child: RateServiceModalContent(), // The actual content widget
      );
    },
  );
}

// The content widget for the modal bottom sheet
class RateServiceModalContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the ViewModel provided above
    final viewModel = Provider.of<RateServiceViewModel>(context);

    return Padding(
      // Adjust padding based on keyboard visibility
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Make the modal height fit content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Rate Your Experience',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'How was your service at ${viewModel.providerName}?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),

          // Star Rating Input
          Center(
            child: StarRating(
              rating: viewModel.rating,
              onRatingChanged: (rating) => viewModel.setRating(rating),
            ),
          ),
          SizedBox(height: 20),

          // Review Text Input
          TextField(
            controller: viewModel.reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your review (optional)...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Error Message
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),

          // Submit Button
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
              bool success = await viewModel.submitReview();
              if (success && context.mounted) {
                Navigator.of(context).pop(); // Close the modal on success
                // Optional: Show a success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thank you for your review!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: viewModel.isLoading
                ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Submit Review', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(height: 20), // Padding at the bottom
        ],
      ),
    );
  }
}

// Simple Star Rating Widget (You might use a package like flutter_rating_bar later)
class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final int starCount;
  final Color color;

  StarRating({
    this.starCount = 5,
    this.rating = 0.0,
    required this.onRatingChanged,
    this.color = Colors.amber,
  });

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(Icons.star_border, color: Colors.grey[400]);
    } else if (index > rating - 1 && index < rating) {
      icon = Icon(Icons.star_half, color: color);
    } else {
      icon = Icon(Icons.star, color: color);
    }
    return InkResponse(
      onTap: () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) => buildStar(context, index)),
    );
  }
}