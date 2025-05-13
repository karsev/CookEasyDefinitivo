import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/home_screen.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:CookEasy/view/widget/custom_text_fild_in_upload.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SecondUploadScreen extends StatefulWidget {
  const SecondUploadScreen({
    Key? key,
    this.pickedFile,
    required this.title,
    required this.description,
    this.preparationTime,
  }) : super(key: key);

  final XFile? pickedFile;
  final String title;
  final String description;
  final String? preparationTime;

  @override
  State<SecondUploadScreen> createState() => _SecondUploadScreenState();
}

class _SecondUploadScreenState extends State<SecondUploadScreen> {
  List<Ingredient> ingredients = [Ingredient(name: '')];
  List<RecipeStep> steps = [RecipeStep(description: '')];
  List<TextEditingController> ingredientNameControllers = [TextEditingController()];
  List<TextEditingController> ingredientQuantityControllers = [TextEditingController()];
  List<TextEditingController> stepControllers = [TextEditingController()];
  bool _isUploading = false;

  @override
  void dispose() {
    for (final controller in ingredientNameControllers) {
      controller.dispose();
    }
    for (final controller in ingredientQuantityControllers) {
      controller.dispose();
    }
    for (final controller in stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget enterIngerediant(int index) {
    return Dismissible(
      key: UniqueKey(),
      direction: ingredients.length > 1
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (direction) {
        setState(() {
          ingredients.removeAt(index);
          ingredientNameControllers.removeAt(index);
          ingredientQuantityControllers.removeAt(index);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: CustomTextFildInUpload(
                controller: ingredientNameControllers[index],
                radius: 30,
                hint: "Nombre del ingrediente",
                icon: Icons.drag_indicator,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomTextFildInUpload(
                controller: ingredientQuantityControllers[index],
                radius: 30,
                hint: "Cantidad (opcional)",
                suffixText: 'g', // Aquí se añade la "g"
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ingrediantsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            ingredients.add(Ingredient(name: ''));
            ingredientNameControllers.add(TextEditingController());
            ingredientQuantityControllers.add(TextEditingController());
          });
        },
        child: Container(
            alignment: Alignment.center,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: SecondaryText),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                Text(
                  "Ingrediente",
                  style: TextStyle(
                      fontSize: 15,
                      color: mainText,
                      fontWeight: FontWeight.w500),
                )
              ],
            )),
      ),
    );
  }

  Widget step(int index) {
    return Dismissible(
      direction: steps.length > 1
          ? DismissDirection.endToStart
          : DismissDirection.none,
      key: UniqueKey(),
      onDismissed: (d) {
        setState(() {
          steps.removeAt(index);
          stepControllers.removeAt(index);
        });
      },
      child: Stack(
        children: [
          Column(
            children: [
              CustomTextFildInUpload(
                controller: stepControllers[index],
                hint: "Cuentanos un poco mas de receta",
                icon: Icons.drag_indicator,
                maxLines: 4,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10, left: 35),
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: form,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 30,
                  color: mainText,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CircleAvatar(
              backgroundColor: mainText,
              radius: 12,
              child: Text(
                "${index + 1}",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _saveRecipeToFirestore(List<Map<String, String>> ingredients, List<String> steps) async {
    print("Llamando a _saveRecipeToFirestore sin imagen.");

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final String recipeId = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance.collection('recipes').doc(recipeId).set({
        'title': widget.title,
        'description': widget.description,
        'imageUrl': null,
        'userId': user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'ingredients': ingredients,
        'steps': steps,
        'cookingTime': widget.preparationTime ?? '',
        'servings': 1,
        'recipeId': recipeId,
        'isUserCreated': true, // Añadido el campo isUserCreated
      });
      openDialog();
      print("Receta guardada exitosamente en Firestore (sin imagen)");
    } catch (e) {
      print("Error saving recipe: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la receta.')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> openDialog() async {
    print("Llamando a openDialog()");
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                padding: const EdgeInsets.all(20),
                height: 400,
                width: 327,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/imges/image 8.png"),
                    Text(
                      "Carga completada",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      "Subido correctamente",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      "La puedes ver en tu perfil",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    CustomButton(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                        text: "Volver a inicio")
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    print("Título recibido en SecondUpload: ${widget.title}");
    print("Picked File: ${widget.pickedFile?.path}");
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: const Color.fromRGBO(77, 67, 58, 1),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancelar",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(color: Secondary),
                              ),
                            ),
                            Text(
                              "2/2",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: SecondaryText),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Ingredientes",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 15),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ingredients.length,
                          itemBuilder: (context, index) {
                            return enterIngerediant(index);
                          },
                        ),
                        ingrediantsButton(),
                        const SizedBox(height: 15),
                        Text(
                          "Pasos",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 15),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: steps.length,
                          itemBuilder: (context, index) {
                            return step(index);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                steps.add(RecipeStep(description: ''));
                                stepControllers.add(TextEditingController());
                              });
                            },
                            child: Container(
                                alignment: Alignment.center,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: SecondaryText),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add),
                                    Text(
                                      "Paso",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: mainText,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_isUploading)
                          const CircularProgressIndicator()
                        else
                          Row(
                            children: [
                              Expanded(
                                  child: CustomButton(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      text: "Anterior")),
                              const SizedBox(width: 20),
                              Expanded(
                                  child: CustomButton(
                                      onTap: () async {
                                        if (_isUploading) {
                                          return;
                                        }
                                        setState(() {
                                          _isUploading = true;
                                        });

                                        List<String> finalIngredients = ingredientNameControllers.map((c) => c.text).toList();
                                        List<String> finalQuantities = ingredientQuantityControllers.map((c) => c.text).toList();
                                        List<String> finalSteps = stepControllers.map((c) => c.text).toList();

                                        List<Map<String, String>> ingredientsList = [];
                                        for (int i = 0; i < finalIngredients.length; i++) {
                                          ingredientsList.add({
                                            'name': finalIngredients[i],
                                            'quantity': finalQuantities[i],
                                          });
                                        }
                                        await _saveRecipeToFirestore(ingredientsList, finalSteps);
                                      },
                                      text: "Siguiente")),
                            ],
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Ingredient {
  String name;
  Ingredient({required this.name});
}

class RecipeStep {
  String description;
  RecipeStep({required this.description});
}