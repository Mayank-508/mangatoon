import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/webtoon_category.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  final List<WebtoonCategory> _favorites = [];

  static const String favoritesKey = 'favorites';

  factory FavoritesManager() {
    return _instance;
  }

  FavoritesManager._internal() {
    _loadFavorites(); // Load favorites from SharedPreferences when the instance is created
  }

  // Add a favorite webtoon and persist it
  Future<void> addFavorite(WebtoonCategory category) async {
    if (!_favorites.contains(category)) {
      _favorites.add(category); // Prevent adding duplicates
      await _saveFavorites(); // Save the updated favorites list
    }
  }

  // Remove a favorite webtoon and persist the change
  Future<void> removeFavorite(WebtoonCategory category) async {
    _favorites.remove(category);
    await _saveFavorites();
  }

  // Get the list of favorite webtoons
  List<WebtoonCategory> getFavorites() {
    return _favorites;
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritesJson = prefs.getString(favoritesKey);
    if (favoritesJson != null) {
      List<dynamic> favoritesList = jsonDecode(favoritesJson);
      _favorites.addAll(
          favoritesList.map((e) => WebtoonCategory.fromMap(e)).toList());
    }
  }

  // Save the current favorites list to SharedPreferences
  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(_favorites.map((e) => e.toMap()).toList());
    await prefs.setString(favoritesKey, jsonString);
  }
}
