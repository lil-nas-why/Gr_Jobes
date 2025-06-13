import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Модель данных рекомендаций
class Recommendation {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  Recommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

final List<Recommendation> recommendations = [
  Recommendation(
    title: 'Подработка и временная работа',
    description: '',
    icon: CupertinoIcons.archivebox,
    color: Colors.blue,
  ),
  Recommendation(
    title: 'Полезные статьи и советы',
    description: '',
    icon: CupertinoIcons.book,
    color: Colors.green,
  ),
  Recommendation(
    title: 'Вакансии рядом с вами',
    description: 'Смотреть',
    icon: Icons.map_outlined,
    color: Colors.purple,
  ),
];

