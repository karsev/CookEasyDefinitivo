// profile_tap.dart
import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/start_screen.dart'; 
import 'package:CookEasy/view/screen/taps/home_tap.dart';
import 'package:CookEasy/view/widget/custom_binary_option.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:CookEasy/view/screen/product_item_screen.dart';

class ProfileTap extends StatefulWidget {
  ProfileTap({
    Key? key,
    this.showFollowBottomInProfile = false,
  }) : super(key: key);
  bool showFollowBottomInProfile;

  @override
  State<ProfileTap> createState() => _ProfileTapState();
}

class _ProfileTapState extends State<ProfileTap> {
  late Future<List<DocumentSnapshot>> _userRecipesFuture;
  TextEditingController _usernameController = TextEditingController();
  String? _currentUsername;
  bool _isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    _userRecipesFuture = _getUserRecipes();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data()?['username'] != null) {
        setState(() {
          _currentUsername = userDoc.data()!['username'] as String;
        });
      }
    }
  }

  Future<List<DocumentSnapshot>> _getUserRecipes() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return [];
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs;
  }

  Future<String> _getUsernameFromUserId(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data()?['username'] != null) {
        return userDoc.data()!['username'] as String;
      }
      return 'Usuario desconocido'; // O algún otro valor por defecto
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
      return 'Usuario desconocido';
    }
  }

  Future<void> _saveUsername() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && _usernameController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {'username': _usernameController.text},
          SetOptions(merge: true), // Para no sobrescribir otros campos
        );
        setState(() {
          _currentUsername = _usernameController.text;
          _isEditingUsername = false;
          FocusScope.of(context).unfocus(); // Ocultar el teclado
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre de usuario guardado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el nombre de usuario: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => StartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(77, 67, 58, 1),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share,
                color: mainText,
              ),
            ),
          ),
        ],
        leading: widget.showFollowBottomInProfile
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: mainText,
                    )),
              )
            : const SizedBox(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromRGBO(77, 67, 58, 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage("assets/imges/Avatar3.png"),
                        ),
                        if (FirebaseAuth.instance.currentUser?.uid != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isEditingUsername = true;
                                _usernameController.text = _currentUsername ?? '';
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: primary,
                              child: Icon(
                                Icons.edit,
                                size: 15,
                                color: Color.fromRGBO(77, 67, 58, 1),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FirebaseAuth.instance.currentUser?.uid != null
                          ? _isEditingUsername
                              ? SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      hintText: _currentUsername ?? "Introduce tu nombre",
                                      hintStyle: const TextStyle(color: SecondaryText),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: primary),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
                              : Text(
                                  _currentUsername ?? FirebaseAuth.instance.currentUser!.uid.substring(0, 8), // Mostrar username o parte del UID
                                  style: Theme.of(context).textTheme.displayMedium,
                                )
                          : const Text("Usuario no autenticado"),
                    ),
                    if (FirebaseAuth.instance.currentUser?.uid != null && _isEditingUsername)
                      ElevatedButton(
                        onPressed: _saveUsername,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: const Color.fromRGBO(77, 67, 58, 1),
                        ),
                        child: const Text("Guardar"),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            FutureBuilder<List<DocumentSnapshot>>(
                              future: _userRecipesFuture,
                              builder: (context, snapshot) {
                                int recipeCount = 0;
                                if (snapshot.hasData) {
                                  recipeCount = snapshot.data!.length;
                                }
                                return Text(
                                  "$recipeCount",
                                  style: Theme.of(context).textTheme.displayMedium,
                                );
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Recetas",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: SecondaryText),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              "789",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Siguiendo",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: SecondaryText),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              "1.200",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Seguidores",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: SecondaryText),
                            )
                          ],
                        ),
                      ],
                    ),
                    widget.showFollowBottomInProfile
                        ? CustomButton(onTap: () {}, text: "Follow")
                        : const SizedBox(
                            height: 20,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CustomBinaryOption(
                    textLeft: "Mis Recetas", // Cambiado a botón
                    onTapLeft: () {
                      setState(() {
                        _userRecipesFuture = _getUserRecipes();
                      });
                    },
                    textStyle: const TextStyle(
                        color:Color.fromARGB(167, 199, 138, 8)), // Mantenemos el estilo
                  ),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: _userRecipesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No recipes found for this user.'));
                      } else {
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1.3,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final recipe = snapshot.data![index];
                            final recipeData =
                                recipe.data() as Map<String, dynamic>;
                            return FutureBuilder<String?>(
                              future: _getUsernameFromUserId(recipeData['userId'] as String? ?? ''),
                              builder: (context, usernameSnapshot) {
                                final recipeAuthor = usernameSnapshot.data ?? 'Usuario desconocido';
                                return CustomProductItemWidget(
                                  key: ValueKey(recipe.id),
                                  title: recipeData['title'] as String? ?? 'Sin título',
                                  imagePath: recipeData['image'] as String? ?? '',
                                  author: recipeAuthor, // Usamos el nombre de usuario
                                  likes: recipeData['likes'] ?? 0,
                                  recipeId: recipe.id,
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}