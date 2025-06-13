import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/vacancy_page.dart';
import 'package:gr_jobs/all_pages/features/vacancy/pages/guest_vacancy_page.dart';
import 'package:gr_jobs/all_pages/features/favourites_vacancy/pages/favourites_vac_page.dart';
import 'package:gr_jobs/all_pages/features/favourites_vacancy/pages/guest_favour_vacancy_page.dart';
import 'package:gr_jobs/all_pages/features/responses/pages/responses_page.dart';
import 'package:gr_jobs/all_pages/features/responses/pages/guest_responses_page.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/pages/profile_page.dart';
import 'package:gr_jobs/all_pages/features/profile_auth/pages/guest_profile_page.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:gr_jobs/all_pages/widgets/navigations/navigation_provider.dart';

class Navigation extends StatefulWidget {
  final bool auth;

  const Navigation({super.key, required this.auth});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  late PageController _pageController;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializePages();
  }

  void _initializePages() {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    if (provider.isAuthenticated) {
      _pages = [
        VacancyPage(),
        FavoritesPage(onSearchVacancies: () {}),
        ResponsesPage(),
        ProfilePage(),
      ];
    } else {
      _pages = [
        const GuestVacancyPage(),
        const GuestFavouritesVacPage(),
        const GuestResponsesPage(),
        const GuestProfilePage(),
      ];
    }
  }

  @override
  void didUpdateWidget(covariant Navigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auth != widget.auth || _pageController.hasClients == false) {
      _pageController.dispose();
      _pageController = PageController(initialPage: _selectedIndex);
      _initializePages();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.green[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 12),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _pageController.jumpToPage(index);
            },
            backgroundColor: Colors.green.shade900,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.lightGreen.shade900,
            color: Colors.white,
            gap: 8,
            padding: const EdgeInsets.all(15),
            tabs: const [
              GButton(icon: HugeIcons.strokeRoundedAiSearch02),
              GButton(icon: HugeIcons.strokeRoundedFavourite),
              GButton(icon: HugeIcons.strokeRoundedTaskDaily01),
              GButton(icon: HugeIcons.strokeRoundedUserAccount),
            ],
          ),
        ),
      ),
    );
  }
}