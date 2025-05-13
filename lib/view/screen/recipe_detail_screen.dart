import 'package:CookEasy/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipeDetails;
  bool _isFavorite = false;

  Future<void> fetchRecipeDetails() async {
    final response = await http.get(
      Uri.parse(
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=f952a6a7b09e45908f1ab1b9bca2c422',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        recipeDetails = json.decode(response.body);

        // 👇 Esta línea es la nueva
        print(recipeDetails); // Verifica si 'image' está presente
      });
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: form,
      appBar: AppBar(
        title: Text(recipeDetails?['title'] ?? 'Recipe Details'),
        backgroundColor: SecondaryText,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
                // Aquí llamaremos a la función para guardar/eliminar de favoritos
                if (_isFavorite) {
                  print('Receta añadida a favoritos: ${recipeDetails?['id']}');
                } else {
                  print(
                      'Receta eliminada de favoritos: ${recipeDetails?['id']}');
                }
              });
            },
          ),
        ],
      ),
      body: recipeDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: recipeDetails!['image'] ?? '',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      recipeDetails!['title'] ?? '',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color:
                              SecondaryText), // Usamos el color de texto secundario para el título
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ready in ${recipeDetails!['readyInMinutes']} minutes',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color:
                              mainText), // Usamos el color de texto principal para el subtítulo
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ingredients:',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              SecondaryText), // Usamos el color de texto secundario para el título de ingredientes
                    ),
                  ),
                  ...recipeDetails!['extendedIngredients']
                          ?.map<Widget>((ingredient) {
                        return ListTile(
                          title: Text(
                            ingredient['original'],
                            style: const TextStyle(
                                color:
                                    mainText), // Usamos el color de texto principal para los ingredientes
                          ),
                        );
                      })?.toList() ??
                      [],
                ],
              ),
            ),
    );
  }
}
