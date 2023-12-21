import 'dart:io';

import 'package:place_app/model/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:sqflite/sqflite.dart' as sqlite;

Future<sqlite.Database> loadDatabase() async {
  final dbPath = await sqlite.getDatabasesPath();
  final db = await sqlite.openDatabase(
    path.join(dbPath, "places.db"),
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE user_places (id TEXT PRIMARY KEY , name TEXT , image TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier() : super([]);

  Future<void> loadData() async {
    final db = await loadDatabase();
    final placesList = await db.query('user_places');
    print(placesList);
    List<Place> places = placesList
        .map(
          (place) => Place(
            id: place['id'] as String,
            name: place['name'] as String,
            image: File(place['image'] as String),
          ),
        )
        .toList();

    state = places;
  }

  void addPlace(Place place) async {
    final Directory appDirectory =
        await syspath.getApplicationDocumentsDirectory();
    final fileName = path.basename(place.image.path);
    final imageLocation = path.join(appDirectory.path, fileName);
    File imageFile = await place.image.copy(imageLocation);

    state = [Place(id: place.id, name: place.name, image: imageFile), ...state];
    final db = await loadDatabase();
    db.insert(
      'user_places',
      {'id': place.id, 'name': place.name, 'image': imageFile.path},
    );
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>(
  (ref) => PlacesNotifier(),
);
