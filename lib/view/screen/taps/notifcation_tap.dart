// Notifications_tap.dart
import 'package:flutter/material.dart';
import 'package:CookEasy/view/widget/custom_follow_notifcation.dart';
import 'package:CookEasy/view/widget/custom_liked_notifcation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotitcationTap extends StatelessWidget {
  NotitcationTap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    print('Current User ID (Build): $currentUserId');

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(77, 67, 58, 1),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notificaciones Recientes",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              _buildRecentNotificationsList(context, currentUserId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNotificationsList(
      BuildContext context, String? currentUserId) {
    print('Current User ID (List Function): $currentUserId');
    final query = FirebaseFirestore.instance
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('createdTimestamp', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        print('StreamBuilder State: ${snapshot.connectionState}');
        if (snapshot.hasError) {
          print('StreamBuilder Error: ${snapshot.error}');
          return Center(child: Text('Algo salió mal: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay notificaciones recientes.'));
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final notification = snapshot.data!.docs[index];
            final notificationData =
                notification.data() as Map<String, dynamic>;
            final type = notificationData['type'];
            print('Notification Type: $type, Data: $notificationData');

            if (type == "follow") {
              return CustomFollowNotifcation(
                emitterId: notificationData['emitterId'] as String?,
                isNewUser: type == "new_user",
              );
            } else if (type == "like") {
              return CustomLikedNotifcation(
                emitterId: notificationData['emitterId'] as String?,
                recipeId: notificationData['recipeId'] as String?,
              );
            } else if (type == "comment") {
              return CustomLikedNotifcation(
                emitterId: notificationData['emitterId'] as String?,
                recipeId: notificationData['recipeId'] as String?,
                commentText: notificationData['commentText'] as String?,
                isComment: true,
              );
            } else if (type == "new_user") {
              return CustomFollowNotifcation(
                emitterId: notificationData['emitterId'] as String?,
                isNewUser: true,
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}