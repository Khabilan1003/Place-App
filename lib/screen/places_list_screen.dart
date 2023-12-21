import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_app/model/place.dart';
import 'package:place_app/provider/places_provider.dart';
import 'package:place_app/screen/add_place_screen.dart';
import 'package:place_app/screen/place_screen.dart';

class PlacesListScreen extends ConsumerStatefulWidget {
  const PlacesListScreen({super.key});

  @override
  ConsumerState<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends ConsumerState<PlacesListScreen> {
  late Future<void> loadDataFuture;

  @override
  void initState() {
    loadDataFuture = ref.read(placesProvider.notifier).loadData();
    super.initState();
  }

  void navigateAddPlaceScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const AddPlaceScreen(),
      ),
    );
  }

  void navigatePlaceScreen(Place place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PlaceScreen(
          place: place,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Places"),
        actions: [
          IconButton(
            onPressed: () => navigateAddPlaceScreen(),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadDataFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return places.isEmpty
                ? Center(
                    child: Text(
                      "No Places added yet",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (ctx, index) => ListTile(
                        onTap: () => navigatePlaceScreen(places[index]),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: FileImage(
                            places[index].image,
                          ),
                        ),
                        title: Text(
                          places[index].name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                        ),
                      ),
                    ),
                  );
          }
        },
      ),
    );
  }
}
