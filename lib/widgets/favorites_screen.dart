import 'package:flutter/material.dart';

import '../managers/favorites_manager.dart';
import '../model/webtoon_category.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<WebtoonCategory>> favorites;

  @override
  void initState() {
    super.initState();
    favorites =
        Future.value(FavoritesManager().getFavorites()); // Load favorites
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Webtoons'),
      ),
      body: FutureBuilder<List<WebtoonCategory>>(
        future: favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading favorites'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorites added yet!'));
          }

          List<WebtoonCategory> favoritesList = snapshot.data!;

          return ListView.builder(
            itemCount: favoritesList.length,
            itemBuilder: (context, index) {
              final favorite = favoritesList[index];
              return ListTile(
                leading: Image.asset(favorite.thumbnailUrl,
                    width: 50, height: 50), // Show thumbnail
                title: Text(favorite.title), // Show title
                subtitle: Text(
                  'Description: ${favorite.description.length > 50 ? favorite.description.substring(0, 50) + '...' : favorite.description}',
                ), // Show truncated description
                trailing: IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await FavoritesManager().removeFavorite(favorite);
                    setState(() {
                      favorites =
                          Future.value(FavoritesManager().getFavorites());
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
