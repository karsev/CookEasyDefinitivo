// services/recipe_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeService {
  final String apiKey =
      'f952a6a7b09e45908f1ab1b9bca2c422'; // ¡Mantén tu API key segura!

  Future<List<dynamic>> getPopularRecipes() async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/complexSearch?sort=popularity&number=10&apiKey=$apiKey'), // Obtener 10 recetas populares
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load popular recipes');
    }
  }

  Future<List<dynamic>> searchRecipes(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/complexSearch?query=$query&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load recipes for query: $query');
    }
  }

  Future<Map<String, dynamic>> getRecipeDetails(int recipeId) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recipe details for ID: $recipeId');
    }
  }
}
