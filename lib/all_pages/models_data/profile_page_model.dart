import 'package:flutter/material.dart';

// Модели данных
class UserProfile {
  final String name;
  UserStatus status; // Изменили на enum тип
  final List<Resume> resumes;
  final bool isPro;
  final CareerStats stats;

  UserProfile({
    required this.name,
    required this.status,
    required this.resumes,
    required this.isPro,
    required this.stats,
  });
}

// Перечисление статусов
enum UserStatus {
  notLooking('Активно ищу работу', Colors.green),
  activelyLooking('Рассматриваю предложения', Colors.green),
  consideringOffers('Предложили работу, думаю', Colors.green),
  openToOffers('Уже выхожу на новое место', Colors.green),
  readyToStart('Не ищу работу', Colors.orange);

  final String text;
  final Color color;

  const UserStatus(this.text, this.color);
}

class Resume {
  final String id;
  final String title;
  final String status;
  final DateTime? autoRaiseDate;
  final WeeklyStats weeklyStats;
  final String recommendation;
  final int matchingVacancies;
  final List<UserVacancy> suggestedVacancies;

  Resume({
    required this.id,
    required this.title,
    required this.status,
    this.autoRaiseDate,
    required this.weeklyStats,
    required this.recommendation,
    required this.matchingVacancies,
    required this.suggestedVacancies,
  });
}

class WeeklyStats {
  final int impressions;
  final int views;
  final int invitations;

  WeeklyStats({
    required this.impressions,
    required this.views,
    required this.invitations,
  });
}

class UserVacancy {
  final String id;
  final String title;
  final DateTime updatedAt;
  final String company;
  final String salary;
  final String location;

  UserVacancy({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.company,
    required this.salary,
    required this.location,
  });
}

class CareerStats {
  final int coursesCompleted;
  final int mentors;
  final int newSkills;

  CareerStats({
    required this.coursesCompleted,
    required this.mentors,
    required this.newSkills,
  });
}