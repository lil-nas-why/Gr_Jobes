import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/favourites_vacancy/widgets/favour_widgets.dart';

class FavoritesPage extends StatelessWidget {
  final VoidCallback? onSearchVacancies;

  const FavoritesPage({super.key, this.onSearchVacancies});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  title: const Text('Избранное'),
                  floating: true,
                  pinned: true,
                  snap: false,
                  expandedHeight: 100,
                  collapsedHeight: kToolbarHeight,
                  forceElevated: innerBoxIsScrolled,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(64),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: const TabBar(
                        isScrollable: true,
                        labelPadding: EdgeInsets.symmetric(horizontal: 16),
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(width: 2, color: Colors.black),
                          insets: EdgeInsets.only(bottom: 8),
                        ),
                        tabs: [
                          Tab(text: 'Вакансии'),
                          Tab(text: 'Подписки'),
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
              FavouritesContent(  // Используем виджет из отдельного файла
                isEmpty: true,
                icon: Icons.favorite_border,
                title: 'Добавьте вакансии\nв избранное',
                subtitle: 'Вы можете вернуться к ним позже, чтобы откликнуться',
                buttonText: 'Искать вакансии',
                onPressed: onSearchVacancies ?? () {},  // Передаём callback
              ),
              FavouritesContent(
                isEmpty: true,
                icon: Icons.notifications_none,
                title: 'Подписывайтесь\nна поиски',
                subtitle: 'Получайте уведомления о новых вакансиях',
                buttonText: 'Создать подписку',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}