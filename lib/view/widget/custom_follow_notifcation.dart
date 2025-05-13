// CustomFollowNotifcation.dart
import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/widget/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomFollowNotifcation extends StatefulWidget {
  final String? emitterId;
  final bool isNewUser;

  const CustomFollowNotifcation({
    Key? key,
    this.emitterId,
    this.isNewUser = false,
  }) : super(key: key);

  @override
  State<CustomFollowNotifcation> createState() =>
      _CustomFollowNotifcationState();
}

class _CustomFollowNotifcationState extends State<CustomFollowNotifcation> {
  bool follow = false;
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
              FutureBuilder<DocumentSnapshot?>(
                future: _emitterDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(radius: 25, backgroundImage: AssetImage("assets/imges/Avatar.png"));
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
                    return const CircleAvatar(radius: 25, backgroundImage: AssetImage("assets/imges/Avatar.png"));
                  } else {
                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    final profileImageUrl = userData['profileImageUrl'] as String?;
                    return CircleAvatar(
                      radius: 25,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl) as ImageProvider<Object>?
                          : const AssetImage("assets/imges/Avatar.png"),
                    );
                  }
                },
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot?>(
                      future: _emitterDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Cargando...");
                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
                          return Text(widget.emitterId ?? "Usuario");
                        } else {
                          final userData = snapshot.data!.data() as Map<String, dynamic>;
                          final username = userData['username'] as String?;
                          return Text(
                            username ?? "Usuario",
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(color: mainText),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.isNewUser
                          ? "Nuevo usuario registrado · h1"
                          : "New following you · h1",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: SecondaryText),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: follow == false ? 50 : 30),
                  child: CustomButton(
                    height: 40,
                    color: follow == false ? primary : form,
                    textColor: follow == false ? Colors.white : mainText,
                    onTap: () {
                      setState(() {
                        follow = !follow;
                      });
                    },
                    text: "Follow",
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