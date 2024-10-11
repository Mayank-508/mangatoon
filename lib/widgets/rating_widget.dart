import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingWidget extends StatefulWidget {
  final String webtoonTitle; // Unique identifier for the webtoon
  final double initialRating; // Initial rating to display
  final ValueChanged<double> onChanged; // Callback for rating change

  RatingWidget({
    required this.webtoonTitle,
    required this.initialRating,
    required this.onChanged,
  });

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _rating; // User's rating
  double _averageRating = 0.0; // Average rating from all users
  int _ratingCount = 0; // Number of ratings given

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating
        .clamp(1.0, 5.0); // Ensure initial rating is within range
    _loadRatings(); // Load saved ratings for this webtoon from SharedPreferences
  }

  // Load ratings from SharedPreferences for this specific webtoon
  Future<void> _loadRatings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load average rating and count
      _averageRating =
          prefs.getDouble('${widget.webtoonTitle}_average_rating') ?? 0.0;
      _ratingCount = prefs.getInt('${widget.webtoonTitle}_rating_count') ?? 0;

      // Load user rating, ensure it's between 1.0 and 5.0
      double userRating =
          prefs.getDouble('${widget.webtoonTitle}_user_rating') ?? 1.0;
      _rating = userRating.clamp(1.0, 5.0); // Ensure user rating is valid
    });
  }

  // Save or update the user's rating and recalculate the average
  Future<void> _saveRatings(double newRating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve previous user rating if it exists
    double? previousRating =
        prefs.getDouble('${widget.webtoonTitle}_user_rating');

    if (previousRating != null) {
      // If updating, adjust the average accordingly
      if (_ratingCount > 0) {
        _averageRating =
            ((_averageRating * _ratingCount) - previousRating + newRating) /
                _ratingCount;
      }
    } else {
      // New rating, increment count
      _ratingCount++; // Increment the count here
      _averageRating =
          ((_averageRating * (_ratingCount - 1)) + newRating) / _ratingCount;
    }

    // Save new rating, average, and count in SharedPreferences
    await prefs.setDouble('${widget.webtoonTitle}_user_rating', newRating);
    await prefs.setDouble(
        '${widget.webtoonTitle}_average_rating', _averageRating);
    await prefs.setInt(
        '${widget.webtoonTitle}_rating_count', _ratingCount); // Save the count

    setState(() {}); // Update the UI with the new average and rating count
  }

  // Build the star rating UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Rate this Webtoon:'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = index +
                      1.0; // Update the rating based on the star clicked
                });
                widget.onChanged(_rating); // Call the onChanged callback
                _saveRatings(_rating); // Save or update the rating
              },
            );
          }),
        ),
        SizedBox(height: 10),
        Text(
          'Average Rating: ${_averageRating.toStringAsFixed(1)} ($_ratingCount ratings)',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
