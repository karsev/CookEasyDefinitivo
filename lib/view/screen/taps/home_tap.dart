import 'dart:async';

import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/receipt_service.dart';
import 'package:CookEasy/view/screen/search_Screen.dart';
import 'package:CookEasy/view/screen/taps/profile_tap.dart';
import 'package:CookEasy/view/screen/product_item_screen.dart';
import 'package:CookEasy/view/widget/custom_Text_Form_fild.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeTap extends StatefulWidget {
  const HomeTap({Key? key}) : super(key: key);

  @override
  State<HomeTap> createState() => _HomeTapState();
}

class _HomeTapState extends State<HomeTap> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<dynamic>> _popularRecipesFuture;
  late Future<List<DocumentSnapshot>> _userRecipesFuture;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _popularRecipesFuture = _recipeService.getPopularRecipes();
    _userRecipesFuture = _fetchAllUserRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<DocumentSnapshot>> _fetchAllUserRecipes() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('recipes').get();
    return querySnapshot.docs;
  }

  Future<String> _getUsernameFromUserId(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data()?['username'] != null) {
        return userDoc.data()!['username'] as String;
      }
      return 'Usuario desconocido';
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
      return 'Usuario desconocido';
    }
  }

  Widget _buildRecipeGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _popularRecipesFuture,
      builder: (context, apiSnapshot) {
        if (apiSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (apiSnapshot.hasError) {
          return Center(child: Text('Error API: ${apiSnapshot.error}'));
        } else if (!apiSnapshot.hasData) {
          return const Center(child: Text('No se encontraron recetas de la API.'));
        }

        return FutureBuilder<List<DocumentSnapshot>>(
          future: _userRecipesFuture,
          builder: (context, userSnapshot) {
            // Mover la lógica de construcción de allRecipes aquí para que se reconstruya con cada snapshot
            List<dynamic> allRecipes = [];
            if (apiSnapshot.hasData) {
              allRecipes.addAll(apiSnapshot.data!);
            }
            if (userSnapshot.hasData) {
              for (var doc in userSnapshot.data!) {
                final recipeData = doc.data() as Map<String, dynamic>;
                allRecipes.add({
                  'id': doc.id,
                  'title': recipeData['title'],
                  'image': recipeData['image'],
                  'authorId': recipeData['userId'],
                  'isUserRecipe': true,
                });
              }
            }

            if (userSnapshot.connectionState == ConnectionState.waiting && apiSnapshot.connectionState != ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (userSnapshot.hasError) {
              return Center(child: Text('Error Usuarios: ${userSnapshot.error}'));
            }

            if (allRecipes.isEmpty && !apiSnapshot.hasError && (userSnapshot.hasError || (userSnapshot.hasData && userSnapshot.data!.isEmpty))) {
              return const Center(child: Text('No se encontraron recetas.'));
            }

            return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1 / 1.3,
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              children: allRecipes.map((recipe) {
                return FutureBuilder<String?>(
                  future: recipe['isUserRecipe'] == true
                      ? _getUsernameFromUserId(recipe['authorId'] as String)
                      : Future.value('Spoonacular'),
                  builder: (context, authorSnapshot) {
                    final author = authorSnapshot.data ?? 'Cargando...';
                    final recipeId = recipe['isUserRecipe'] == true ? recipe['id'] : (recipe['id'] as int? ?? 0).toString();
                    return CustomProductItemWidget(
                      key: ValueKey(recipeId),
                      title: recipe['title'] ?? 'Sin título',
                      imagePath: recipe['image'] as String? ?? '',
                      author: author,
                      likes: recipe['likes'] ?? 0,
                      recipeId: recipeId,
                      isUserRecipe: recipe['isUserRecipe'] ?? false,
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: form,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SearchScreen()),
                              );
                            },
                            child: CostomTextFormFild(
                              controller: _searchController,
                              hint: "Buscar",
                              prefixIcon: IconlyLight.search,
                              filled: true,
                              enabled: false, // Para que no se pueda escribir directamente aquí
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row( // Aquí empiezan los botones de categoría
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Acción para mostrar solo recetas de la API
                                  setState(() {
                                    _popularRecipesFuture = _recipeService.getPopularRecipes();
                                    _userRecipesFuture = Future.value([]); // Limpiar recetas de usuario
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 228, 152, 11), // Fondo blanco
                                  foregroundColor: const Color.fromRGBO(77, 67, 58, 1), // Texto marrón oscuro
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                                  ),
                                ),
                                child: const Text('Recetas Populares'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Acción para mostrar solo recetas de usuarios
                                  setState(() {
                                    _popularRecipesFuture = Future.value([]); // Limpiar recetas de la API
                                    _userRecipesFuture = _fetchAllUserRecipes();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 228, 152, 11), // Fondo blanco
                                  foregroundColor: const Color.fromRGBO(77, 67, 58, 1), // Texto marrón oscuro
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                                  ),
                                ),
                                child: const Text('Recetas de Usuarios'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: const Color.fromRGBO(77, 67, 58, 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildRecipeGrid(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomProductItemWidget extends StatefulWidget {
  final String title;
  final String imagePath;
  final String author;
  final int likes;
  final String recipeId;
  final bool isUserRecipe;

  const CustomProductItemWidget({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.author,
    required this.likes,
    required this.recipeId,
    this.isUserRecipe = false,
  }) : super(key: key);

  @override
  State<CustomProductItemWidget> createState() =>
      _CustomProductItemWidgetState();
}

class _CustomProductItemWidgetState extends State<CustomProductItemWidget> {
  late bool _isLiked;
  late int _likeCount;
  late Future<bool> _isLikedFuture;
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();
  int _commentCount = 0;
  late StreamSubscription<QuerySnapshot>? _commentsSubscription;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likes; // Inicializar con los likes recibidos
    _isLikedFuture = _checkIfLiked().then((liked) {
      setState(() {
        _isLiked = liked;
        if (!_isLiked && _likeCount > widget.likes) {
          _likeCount = widget.likes; // Asegurar que no sea menor que el original
        } else if (_isLiked && _likeCount < widget.likes + 1) {
          _likeCount = widget.likes + 1; // Asegurar que no sea mayor que el original + 1
        }
      });
      return liked;
    });
    _subscribeToCommentCount();
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToCommentCount() {
    _commentsSubscription = FirebaseFirestore.instance
        .collection('comments')
        .where('recipeId', isEqualTo: widget.recipeId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _commentCount = snapshot.size;
      });
    });
  }

  Future<bool> _checkIfLiked() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    final likeRef = FirebaseFirestore.instance
        .collection('recipe_likes')
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: widget.recipeId)
        .limit(1);
    final snapshot = await likeRef.get();
    return snapshot.docs.isNotEmpty;
  }

  void _toggleLike(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Usuario no autenticado, no se puede dar like.');
      return;
    }

    final likeRef = FirebaseFirestore.instance
        .collection('recipe_likes')
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: widget.recipeId)
        .limit(1);

    try {
      final snapshot = await likeRef.get();

      setState(() {
        if (_isLiked) {
          if (snapshot.docs.isNotEmpty) {
            FirebaseFirestore.instance
                .collection('recipe_likes')
                .doc(snapshot.docs.first.id)
                .delete();
            _likeCount--;
            _isLiked = false;
          }
        } else {
          FirebaseFirestore.instance.collection('recipe_likes').add({
            'userId': userId,
            'recipeId': widget.recipeId,
            'timestamp': FieldValue.serverTimestamp(),
          });
          _likeCount++;
          _isLiked = true;
        }
      });
      _isLikedFuture = _checkIfLiked();
    } catch (error) {
      print('Error al dar/quitar like: $error');
    }
  }

  void _toggleShowComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  void _postComment() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Usuario no autenticado, no se puede comentar.');
      return;
    }
    final commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('comments').add({
          'userId': userId,
          'recipeId': widget.recipeId,
          'text': commentText,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _commentController.clear();
      } catch (error) {
        print('Error al publicar comentario: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProductItemScreen(recipeId: widget.recipeId)),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        color: Colors.white, // Fondo blanco para la tarjeta
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Bordes redondeados para la tarjeta
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imagePath.isNotEmpty)
              ClipRRect( // Para redondear las esquinas de la imagen
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  widget.imagePath,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              )
            else
              const SizedBox(
                width: double.infinity,
                height: 120,
                child: Center(child: Icon(Icons.image_not_supported)),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(77, 67, 58, 1)), // Título marrón oscuro
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfileTap(showFollowBottomInProfile: true)),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 16, // Reducido el radio del avatar
                      backgroundImage: AssetImage("assets/imges/avatar.png"),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.author,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.grey[600]), // Autor en un gris más suave
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<bool>(
                    future: _isLikedFuture,
                    builder: (context, snapshot) {
                      final liked = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : Colors.grey[600]!,
                          size: 16,
                        ),
                        onPressed: () => _toggleLike(context),
                      );
                    },
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "$_likeCount",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    IconlyLight.chat,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "$_commentCount",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: _toggleShowComments,
                child: Text(
                    _showComments ? 'Ocultar comentarios' : 'Ver comentarios',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ),
            if (_showComments)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0), // Menor padding general
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _commentController,
                            style: const TextStyle(
                                fontSize: 9), // Tamaño de texto reducido
                            decoration: const InputDecoration(
                              hintText: 'Escribe un comentario...',
                              hintStyle:
                                  TextStyle(fontSize: 9), // Tamaño del hint
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 7,
                                  horizontal: 7), // Reduce espacio interno
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, size: 14),
                          onPressed: _postComment,
                          padding:
                              const EdgeInsets.all(4), // Reduce padding interno
                          constraints:
                              const BoxConstraints(), // Elimina restricciones de tamaño mínimo
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .where('recipeId', isEqualTo: widget.recipeId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Algo salió mal al cargar los comentarios'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('No hay comentarios aún. ¡Sé el primero!', style: TextStyle(color: Colors.grey[600])),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final comment = snapshot.data!.docs[index];
                          final commentData =
                              comment.data() as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 2.0), // Ligeramente reducido
                            child: ListTile(
                              leading: const CircleAvatar(
                                radius: 14, // Ligeramente reducido
                                backgroundImage:
                                    AssetImage("assets/imges/avatar.png"),
                              ),
                              title: Text(
                                commentData['text'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87),
                              ),
                              subtitle: Text(
                                '${commentData['userId'] ?? 'Usuario desconocido'} - ${(commentData['timestamp'] as Timestamp?)?.toDate().toString().split('.').first ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontSize: 10, color: Colors.grey[600]),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                  horizontal: 12.0), // Ligeramente reducido
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}