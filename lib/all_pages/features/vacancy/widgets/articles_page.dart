import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesPage extends StatefulWidget {
  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ));

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7)));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Статьи"),
      ),
      body: ListView(
        children: [
          _buildArticleCard(
            context,
            title: "Цифровизация: друг или враг",
            description: "Вы когда-нибудь слышали про цифровой стресс, диджитал-выгорание...",
            imageUrl: "https://avatars.mds.yandex.net/i?id=78be653607da6599ee62dcc9a63e2ccb_l-8767819-images-thumbs&n=13",
            url: "https://ug.ru/tak-drug-nam-czifra-ili-vrag/",
          ),
          _buildArticleCard(
            context,
            title: "Как в 2025 начать работать в IT-сфере без опыта",
            description: "Как найти работу в IT- сфере, когда все ее уже давно нашли? В статье расскажем, кто востребован, куда берут без опыта, как составить резюме и пройти собеседование...",
            imageUrl: "https://tproger.ru/signed_image/urCjvDnVy7-TbgxV1PsrUXHgNRLJhIR-rema6bVH_00/rs:fill:766:0:true/cb:vimg_2/f:webp/aHR0cHM6Ly9tZWRpYS50cHJvZ2VyLnJ1L3VwbG9hZHMvMjAyNS8wMi8yOWFlMWFkMS1mYTJiLTQxNDctOTNiNS1hYjYwMmY4YmVhOWYuanBn",
            url: "https://tproger.ru/articles/poetapno-razbiraemsya--kak-v-2025-nachat-rabotat-v-it-sfere-bez-opyta",
          ),
          _buildArticleCard(
            context,
            title: "Что написать в резюме в разделе «О себе»?",
            description: "Еще он может называться «Обо мне»",
            imageUrl: "https://cdn1-media.rabota.ru/processor/blogs/header_decor_800/2024/04/25/o-sebe_2.jpg.avif",
            url: "https://prosto.rabota.ru/post/chto-napisat-v-rezyume-v-razdele-o-sebe/",
          ),
          _buildArticleCard(
            context,
            title: "Как проходит ярмарка вакансий?",
            description: "Кому они полезны и как на них найти работу...",
            imageUrl: "https://cdn1-media.rabota.ru/processor/blogs/header_decor_800/2024/11/23/image.jpg.avif",
            url: "https://prosto.rabota.ru/post/yarmarka-vakansij/",
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, {
    required String title,
    required String description,
    required String imageUrl,
    required String url,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () async {
          // Открытие ссылки во внешнем браузере
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Не удалось открыть ссылку")),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}