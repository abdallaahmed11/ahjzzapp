import 'package:flutter/material.dart';
// import 'package:ahjizzzapp/services/db_service.dart'; // For saving the review

class RateServiceViewModel extends ChangeNotifier {
  // final DbService _dbService; // To save the review
  final String bookingId; // ID of the booking being reviewed
  final String providerName; // Name to display

  double _rating = 0.0; // Current star rating
  final reviewController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  double get rating => _rating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // RateServiceViewModel(this._dbService, this.bookingId, this.providerName); // Future constructor
  RateServiceViewModel(this.bookingId, this.providerName); // Temporary constructor

  void setRating(double newRating) {
    if (_rating != newRating) {
      _rating = newRating;
      notifyListeners();
    }
  }

  Future<bool> submitReview() async {
    if (_rating == 0.0) {
      _errorMessage = "Please select a star rating.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement logic to save the review using _dbService
      // await _dbService.submitReview(
      //   bookingId: bookingId,
      //   rating: _rating,
      //   reviewText: reviewController.text,
      // );
      print("Submitting Review: Rating=$_rating, Text='${reviewController.text}' for Booking ID: $bookingId");
      await Future.delayed(Duration(seconds: 1)); // Simulate network call

      _isLoading = false;
      notifyListeners();
      return true; // Success

    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to submit review. Please try again.";
      notifyListeners();
      return false; // Failed
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}