import 'package:CookEasy/view/screen/product_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  
  get recipeId => null;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List recipes = [];

  Future<void> fetchRecipes(String query) async {
    if (query.isEmpty) {
      setState(() {
        recipes.clear();
      });
      return;
    }

    // Imprime el término de búsqueda para verificar
    print('Término de búsqueda: $query');

    final String encodedQuery = Uri.encodeComponent(query);
    final String apiKey = 'f952a6a7b09e45908f1ab1b9bca2c422'; // Reemplaza si es necesario
    final String url =
        'https://api.spoonacular.com/recipes/complexSearch?query=$encodedQuery&number=10&apiKey=$apiKey';

    // Imprime la URL completa
    print('URL de búsqueda: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recipes = data['results'];
        print(data); // Imprime la respuesta completa para inspeccionar
      });
    } else {
      print('Error al cargar recetas: ${response.statusCode}');
      throw Exception('Failed to load recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(77, 67, 58, 1),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // Search Bar
              Container(
                color: const Color.fromRGBO(77, 67, 58, 1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Buscar",
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.white),
                            suffixIcon: searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        searchController.clear();
                                        recipes.clear();
                                      });
                                    },
                                  ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (query) {
                            fetchRecipes(query);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Recipe List
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CachedNetworkImage(
                        imageUrl: recipe['image'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      title: Text(
                        recipe['title'] ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          RecipeDetailScreen(recipeId: recipe['id']), // Usa recipe['id']
    ),
  );
},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}