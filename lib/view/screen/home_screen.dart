import 'package:CookEasy/constants/colors.dart';
import 'package:CookEasy/view/screen/taps/home_tap.dart';
import 'package:CookEasy/view/screen/taps/notifcation_tap.dart';
import 'package:CookEasy/view/screen/taps/profile_tap.dart';
import 'package:CookEasy/view/screen/taps/scan_tap.dart';
import 'package:CookEasy/view/screen/taps/upload_tap.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currenIndex = 0;

  final List<Widget> taps = [
    const HomeTap(),
    const UploadTap(),
    NotitcationTap(),
    ProfileTap(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: _bottomNavigationBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF5D4524), // Café oscuro
                Color(0xFFB29068), // Café claro
              ],
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: taps[_currenIndex],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currenIndex,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey[400],
      selectedFontSize: 14,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      backgroundColor: form,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _currenIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(IconlyBold.home),
          label: "Inicio",
        ),
        BottomNavigationBarItem(
          icon: Icon(IconlyBold.edit),
          label: "Cargar",
        ),
        BottomNavigationBarItem(
          icon: Icon(IconlyBold.notification),
          label: "Notificaciones",
        ),
        BottomNavigationBarItem(
          icon: Icon(IconlyBold.profile),
          label: "Perfil",
        ),
      ],
    );
  }
  Widget _scanOption({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 170,
        width: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: outline),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(imagePath, height: 100, width: 100),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: mainText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
