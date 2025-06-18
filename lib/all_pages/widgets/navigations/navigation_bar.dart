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

import '../../features/vacancy/pages/filtered_vacancies_page.dart';

class Navigation extends StatefulWidget {
  final bool auth;

  const Navigation({super.key, required this.auth});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NavigationProvider>(context, listen: false);
      provider.initializePages(widget.auth);

      // Здесь можно безопасно получить AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.appUser == null) {
        authProvider.fetchUser(authProvider.authUser!.id); // Не используем userId напрямую
      }
    });
  }


  @override
  void didUpdateWidget(covariant Navigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auth != widget.auth) {
      final provider = Provider.of<NavigationProvider>(context, listen: false);
      provider.initializePages(widget.auth);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Первая вкладка - Вакансии
              provider.searchTerm == null || provider.filteredVacancies == null
                  ? widget.auth
                  ? const VacancyPage()
                  : const GuestVacancyPage()
                  : FilteredVacanciesPage(
                searchTerm: provider.searchTerm!,
                vacancies: provider.filteredVacancies!,
                onBack: () {
                  provider.clearSearch();
                  _pageController.jumpToPage(0);
                },
              ),
              // Вторая вкладка - Избранное
              widget.auth
                  ? FavoritesPage()
                  : const GuestFavouritesVacPage(),
              // Третья вкладка - Отклики
              widget.auth ? const ApplicationsPage() : const GuestResponsesPage(),
              // Четвертая вкладка - Профиль
              widget.auth ? const ProfilePage() : const GuestProfilePage(),
            ],
            onPageChanged: (index) {
              provider.setCurrentIndex(index);
            },
          ),
          bottomNavigationBar: Container(
            color: Colors.green[900],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 12),
              child: GNav(
                selectedIndex: provider.currentIndex,
                onTabChange: (index) {
                  provider.setCurrentIndex(index);
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
      },
    );
  }
}