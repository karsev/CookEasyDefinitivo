// ProductItemScreen.dart
import 'dart:ui';
import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/receipt_service.dart'; // Importa el servicio
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItemScreen extends StatefulWidget {
  final String recipeId;

  const ProductItemScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  State<ProductItemScreen> createState() => _ProductItemScreenState();
}

class _ProductItemScreenState extends State<ProductItemScreen> {
  final RecipeService _recipeService = RecipeService();
  Future<Map<String, dynamic>>? _recipeDetailsFuture;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _firestoreRecipeFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
  }

  void _loadRecipeDetails() {
    print('Recipe ID recibido en ProductItemScreen: ${widget.recipeId}');
    if (widget.recipeId.length == 13) { // Asumiendo que los IDs de Firestore tienen 20 caracteres
      print('Intentando cargar desde Firestore con ID: ${widget.recipeId}');
      _firestoreRecipeFuture = FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .get();
      _recipeDetailsFuture = null;
    } else {
      final intRecipeId = int.tryParse(widget.recipeId);
      if (intRecipeId != null) {
        print('Intentando cargar desde la API con ID: $intRecipeId');
        _recipeDetailsFuture = _recipeService.getRecipeDetails(intRecipeId);
        _firestoreRecipeFuture = null;
      } else {
        print('Error: ID inválido: ${widget.recipeId}');
        // Manejar el error o mostrar un mensaje
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 300, // Ajusta la altura según sea necesario
              child: _recipeDetailsFuture != null
                  ? FutureBuilder<Map<String, dynamic>>(
                      future: _recipeDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          final recipeDetails = snapshot.data!;
                          final imageUrl = recipeDetails['image'] as String?;
                          return _buildImage(imageUrl);
                        } else {
                          return _buildImage(null);
                        }
                      },
                    )
                  : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: _firestoreRecipeFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData && snapshot.data!.exists) {
                          final recipeData = snapshot.data!.data()!;
                          final imageUrl = recipeData['image'] as String?;
                          return _buildImage(imageUrl);
                        } else {
                          return _buildImage(null);
                        }
                      },
                    ),
            ),
            buttonArrow(context),
            _recipeDetailsFuture != null
                ? _buildApiDetailsScroll()
                : _buildFirestoreDetailsScroll(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset("assets/imges/Food Picture.png", fit: BoxFit.cover); // Imagen por defecto si falla
            },
          )
        : Image.asset("assets/imges/Food Picture.png", fit: BoxFit.cover); // Imagen por defecto si no hay URL
  }

  buttonArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Color.fromRGBO(77, 67, 58, 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApiDetailsScroll() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(77, 67, 58, 1),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: FutureBuilder<Map<String, dynamic>>(
              future: _recipeDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final recipeDetails = snapshot.data!;
                  return _buildRecipeDetails(recipeDetails);
                } else {
                  return const Center(child: Text('No se encontraron detalles de la receta.'));
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFirestoreDetailsScroll() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(77, 67, 58, 1),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _firestoreRecipeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.exists) {
                  final recipeDetails = snapshot.data!.data()!;
                  return _buildRecipeDetails(recipeDetails);
                } else {
                  return const Center(child: Text('No se encontraron detalles de la receta.'));
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeDetails(Map<String, dynamic> recipeDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 5,
                width: 35,
                color: Colors.black12,
              ),
            ],
          ),
        ),
        Text(
          recipeDetails['title'] ?? 'Sin título',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 10),
        Text(
          recipeDetails['readyInMinutes'] != null
              ? 'Listo en ${recipeDetails['readyInMinutes']} mins'
              : (recipeDetails['prepTime'] != null && recipeDetails['cookTime'] != null)
                  ? 'Prep: ${recipeDetails['prepTime']} mins, Cook: ${recipeDetails['cookTime']} mins'
                  : 'Tiempo no disponible',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: SecondaryText),
        ),
        const SizedBox(height: 15),
        // ... (Aquí iría la información del autor, que la API no proporciona directamente en esta llamada)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 4),
        ),
        Text(
          "Descripción",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 10),
        Text(
          recipeDetails['summary'] ?? recipeDetails['description'] ?? 'Sin descripción',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: SecondaryText),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 4),
        ),
        Text(
          "Ingredientes",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 10),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: (recipeDetails['extendedIngredients'] as List?)?.length ?? (recipeDetails['ingredients'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            final ingredient = (recipeDetails['extendedIngredients'] as List?)?[index] ?? (recipeDetails['ingredients'] as List?)?[index];
            final ingredientName = ingredient?['original'] ?? ingredient?['name'] ?? 'N/A';
            return ingredients(context, ingredientName);
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 4),
        ),
        Text(
          "Pasos",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 10),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: (recipeDetails['analyzedInstructions'] as List?)?.isNotEmpty == true
              ? (recipeDetails['analyzedInstructions']?[0]?['steps'] as List?)?.length ?? 0
              : (recipeDetails['steps'] as List?)?.length ?? 0,
          itemBuilder: (context, index) {
            final step = (recipeDetails['analyzedInstructions'] as List?)?[0]?['steps']?[index];
            final stepText = step?['step'] as String? ?? (recipeDetails['steps'] as List?)?[index] as String? ?? 'N/A';
            return steps(context, index, stepText);
          },
        ),
      ],
    );
  }

  ingredients(BuildContext context, String ingredientName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 10,
            backgroundColor: Color.fromRGBO(77, 67, 58, 1),
            child: Icon(
              Icons.done,
              size: 15,
              color: primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredientName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  steps(BuildContext context, int index, String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: mainText,
            radius: 12,
            child: Text("${index + 1}"),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              step,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: mainText),
            ),
          ),
        ],
      ),
    );
  }
}