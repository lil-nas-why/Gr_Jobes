import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/favourites_vacancy/widgets/favour_widgets.dart';
import 'package:gr_jobs/all_pages/features/favourites_vacancy/widgets/favorite_vacancy_card.dart';
import 'package:gr_jobs/all_pages/service/user_service.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';

class FavoritesPage extends StatefulWidget {
  final VoidCallback? onSearchVacancies;

  const FavoritesPage({super.key, this.onSearchVacancies});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  void _loadFavorites() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vacancyProvider = Provider.of<VacancyProvider>(context, listen: false);

    if (userProvider.user != null) {
      vacancyProvider.fetchFavoriteVacancies(userProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  title: const Text(
                    'Избранное',
                    style: TextStyle(color: Colors.black),
                  ),
                  floating: true,
                  pinned: true,
                  snap: false,
                  expandedHeight: 100,
                  collapsedHeight: kToolbarHeight,
                  forceElevated: innerBoxIsScrolled,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      child: TabBar(
                        isScrollable: true,
                        labelPadding: EdgeInsets.zero,
                        padding: const EdgeInsets.only(right: 16),
                        indicator: const UnderlineTabIndicator(
                          borderSide: BorderSide(width: 2, color: Colors.black),
                          insets: EdgeInsets.only(bottom: 8),
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Tab(text: 'Вакансии'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Tab(text: 'Подписки'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildFavoritesTab(),
              // For the second tab, use a simple Column or other widget instead of CustomScrollView
              // if your FavouritesContent uses CustomScrollView with SliverOverlapInjector
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 24),
                      Text(
                        'Подписывайтесь\nна поиски',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Получайте уведомления о новых вакансиях',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Создать подписку'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer2<VacancyProvider, UserProvider>(
      builder: (context, vacancyProvider, userProvider, _) {
        if (vacancyProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vacancyProvider.favoriteVacancies.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'Добавьте вакансии\nв избранное',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Вы можете вернуться к ним позже, чтобы откликнуться',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: widget.onSearchVacancies ?? () {},
                    child: Text('Искать вакансии'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (userProvider.user != null) {
              await vacancyProvider.fetchFavoriteVacancies(userProvider.user!.id);
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final vacancy = vacancyProvider.favoriteVacancies[index];
                      return FavoriteVacancyCard(
                        vacancy: vacancy,
                        onRemove: () async {
                          if (userProvider.user != null) {
                            await vacancyProvider.unfavoriteVacancy(
                              userProvider.user!.id,
                              vacancy.id,
                            );
                            await vacancyProvider.fetchFavoriteVacancies(
                                userProvider.user!.id);
                          }
                        },
                      );
                    },
                    childCount: vacancyProvider.favoriteVacancies.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}