import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../managers/favorites_manager.dart';
import '../model/webtoon_category.dart';
import '../widgets/rating_widget.dart';

class DetailScreen extends StatefulWidget {
  final WebtoonCategory category;

  DetailScreen({required this.category});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool isFavorite;
  double _userRating = 1.0; // Default user rating
  double _averageRating = 0.0; // Average rating from all users
  int _ratingCount = 0; // Number of ratings given

  @override
  void initState() {
    super.initState();
    isFavorite = FavoritesManager().getFavorites().contains(widget.category);
    _loadUserRating(); // Load user's past rating from SharedPreferences
  }

  // Load user rating, average rating, and count from SharedPreferences
  Future<void> _loadUserRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRating = prefs.getDouble('${widget.category.title}_user_rating') ??
          1.0; // Default to 1.0
      _averageRating =
          prefs.getDouble('${widget.category.title}_average_rating') ??
              0.0; // Load average rating
      _ratingCount = prefs.getInt('${widget.category.title}_rating_count') ??
          0; // Load rating count
    });
  }

  void toggleFavorite() async {
    if (isFavorite) {
      await FavoritesManager().removeFavorite(widget.category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.category.title} removed from favorites!'),
        ),
      );
    } else {
      await FavoritesManager().addFavorite(widget.category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.category.title} added to favorites!'),
        ),
      );
    }

    setState(() {
      isFavorite = !isFavorite; // Toggle the favorite state
    });
  }

  void _updateRating(double newRating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve previous user rating if it exists
    double? previousRating =
        prefs.getDouble('${widget.category.title}_user_rating');

    if (previousRating != null) {
      // User has rated before: update the average
      _averageRating =
          ((_averageRating * _ratingCount) - previousRating + newRating) /
              _ratingCount;
    } else {
      // First rating from the user: increment the count
      _ratingCount++;
      _averageRating =
          ((_averageRating * (_ratingCount - 1)) + newRating) / _ratingCount;
    }

    // Save the new user rating, updated average rating, and count in SharedPreferences
    await prefs.setDouble('${widget.category.title}_user_rating', newRating);
    await prefs.setDouble(
        '${widget.category.title}_average_rating', _averageRating);
    await prefs.setInt('${widget.category.title}_rating_count', _ratingCount);

    // Update local user rating for UI
    setState(() {
      _userRating = newRating; // Update the UI to reflect the new user rating
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(widget.category.thumbnailUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.category.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.category.description,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            RatingWidget(
              initialRating: _userRating,
              onChanged: (rating) {
                print('Rating changed to: $rating');
                _updateRating(rating);
              },
              webtoonTitle: widget.category.title,
            ),
            SizedBox(height: 12),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15.0),
              child: ElevatedButton.icon(
                onPressed: toggleFavorite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Button color
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Increased padding
                  textStyle: TextStyle(fontSize: 18), // Increased text size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white, // Icon color
                ),
                label: Text(
                  isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
