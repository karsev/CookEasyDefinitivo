// CustomLikedNotifcation.dart
import 'package:CookEasy/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomLikedNotifcation extends StatefulWidget {
  final String? emitterId;
  final String? recipeId;
  final String? commentText;
  final bool isComment;

  const CustomLikedNotifcation({
    Key? key,
    this.emitterId,
    this.recipeId,
    this.commentText,
    this.isComment = false,
  }) : super(key: key);

  @override
  State<CustomLikedNotifcation> createState() => _CustomLikedNotifcationState();
}

class _CustomLikedNotifcationState extends State<CustomLikedNotifcation> {
  Future<DocumentSnapshot?>? _emitterDataFuture;

  @override
  void initState() {
    super.initState();
    _emitterDataFuture = _getEmitterData();
  }

  Future<DocumentSnapshot?> _getEmitterData() async {
    final emitterId = widget.emitterId;
    if (emitterId != null) {
      try {
        return await FirebaseFirestore.instance.collection('users').doc(emitterId).get();
      } catch (e) {
        print("Error al obtener datos del emisor: $e");
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: FutureBuilder<DocumentSnapshot?>(
                    future: _emitterDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(radius: 25, backgroundImage: AssetImage("assets/imges/Avatar3.png"));
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
                        return const CircleAvatar(radius: 25, backgroundImage: AssetImage("assets/imges/Avatar3.png"));
                      } else {
                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        final profileImageUrl = userData['profileImageUrl'] as String?;
                        return CircleAvatar(
                          radius: 25,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl) as ImageProvider<Object>?
                              : const AssetImage("assets/imges/Avatar3.png"),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      FutureBuilder<DocumentSnapshot?>(
        future: _emitterDataFuture,
        builder: (context, snapshot) {
          String emitterUsername = widget.emitterId ?? "Usuario";
          if (snapshot.connectionState == ConnectionState.waiting) {
            emitterUsername = "Cargando...";
          } else if (!snapshot.hasError && snapshot.hasData && snapshot.data!.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            emitterUsername = userData['username'] as String? ?? "Usuario";
          }

          return RichText(
            maxLines: 2,
            text: TextSpan(
              children: [
                TextSpan(
                  text: emitterUsername,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(color: mainText),
                ),
                TextSpan(
                  text: widget.isComment
                      ? " ha comentado tu receta: \n"
                      : " le ha gustado tu receta \n",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: SecondaryText),
                ),
                if (widget.commentText != null && widget.isComment)
                  const TextSpan(
                    text: '"',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                if (widget.commentText != null && widget.isComment)
                  TextSpan(
                    text: widget.commentText,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                if (widget.commentText != null && widget.isComment)
                  const TextSpan(
                    text: '"',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                const TextSpan(text: " · h1"),
              ],
            ),
          );
        },
      ),
    ],
  ),
),
              const SizedBox(width: 12),
              // Eliminamos el SizedBox que contenía la imagen de la receta
            ],
          ),
        ),
      ),
    );
  }
}