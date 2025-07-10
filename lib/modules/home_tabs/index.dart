import 'package:flutter/material.dart';
import 'package:moniback/modules/home_tabs/pages/accounts.dart';
import 'package:moniback/modules/home_tabs/pages/pin.dart';
import 'package:moniback/modules/home_tabs/pages/my_deals.dart';
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/utils/constants/app_colors.dart';
import 'package:moniback/utils/constants/app_images.dart';
import 'package:moniback/modules/home_tabs/pages/home.dart';
import 'package:moniback/utils/widget/card.dart';
import 'package:moniback/utils/widget/tab_button.dart';
import 'package:provider/provider.dart';

class indexPage extends StatefulWidget {
  final token;
  const indexPage({required this.token, super.key});

  @override
  State<indexPage> createState() => _indexPageState();
}

class _indexPageState extends State<indexPage> {
  int _currentIndex = 0;

  List<Widget> _pages = [];

  final List<List<Widget>> _actions = [
    [
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.settings, color: Colors.black),
      ),
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.notifications_outlined, color: Colors.black),
      ),
    ],
    [
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.search_outlined, color: Colors.black),
      ),
    ],
    [],
    [
      IconButton(
        onPressed: () {},
        icon: Icon(Icons.file_download_outlined, color: Colors.black),
      ),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      Home(
        token: widget.token,
      ),
      MyDeals(
        token: widget.token,
      ),
      Pin(
        token: widget.token,
      ),
      Account( token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   title:  _titles[_currentIndex],
      //   centerTitle: false,
      //   actions: _actions[_currentIndex],
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
          print(_currentIndex);
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              AppImages.home, 
              width: 30,
              height: 30,
            ),
            activeIcon: Container(
              width: 40, 
              height: 40, 
              decoration: const BoxDecoration(
                color: AppColor.primaryColor, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Image.asset(
                  AppImages.home, // Selected image
                  width: 30,// color: AppColor.primaryColor,
                  height: 30,
                ),
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              AppImages.deal, // Unselected image
              width: 24,
              height: 24,
            ),
            activeIcon: Container(
              width: 40, 
              height: 40, 
              decoration: const BoxDecoration(
                color: AppColor.primaryColor, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Image.asset(
                  AppImages.deal, // Selected image
                  width: 30,// color: AppColor.primaryColor,
                  height: 30,
                ),
              ),
            ),
            label: "My Deals",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              AppImages.pin, // Unselected image
              width: 24,
              height: 24,
            ),
            activeIcon:  Container(
              width: 40, 
              height: 40, 
              decoration: const BoxDecoration(
                color: AppColor.primaryColor, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Image.asset(
                  AppImages.pin, // Selected image
                  width: 30,// color: AppColor.primaryColor,
                  height: 30,
                ),
              ),
            ),
            label: "PIN",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              AppImages.profile, // Unselected image
              width: 24,
              height: 24,
            ),
            activeIcon:  Container(
              width: 40, 
              height: 40, 
              decoration: const BoxDecoration(
                color: AppColor.primaryColor, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Image.asset(
                  AppImages.profile, // Selected image
                  width: 30,// color: AppColor.primaryColor,
                  height: 30,
                ),
              ),
            ),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
