import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:gr_jobs/all_pages/models_supabase/vacancy_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class VacanciesMapScreen extends StatefulWidget {
  final List<Vacancy> vacancies;
  final Point initialPoint;
  final double initialRadius;

  const VacanciesMapScreen({
    super.key,
    required this.vacancies,
    required this.initialPoint,
    this.initialRadius = 1000,
  });

  @override
  State<VacanciesMapScreen> createState() => _VacanciesMapScreenState();
}

class _VacanciesMapScreenState extends State<VacanciesMapScreen> {
  YandexMapController? mapController;
  final List<MapObject> mapObjects = [];
  double currentRadius = 1000;
  Point? currentCenter;
  List<Vacancy> filteredVacancies = [];
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    currentRadius = widget.initialRadius;
    currentCenter = widget.initialPoint;
    filteredVacancies = _filterVacanciesInRadius();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ));
  }

  @override
  void dispose() {
    mapController?.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
    ));
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Геолокация отключена')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Доступ к геолокации запрещен')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Разрешите доступ к геолокации в настройках')),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      currentCenter = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _moveToLocation(currentCenter!);
    });
  }

  Future<void> _zoomIn() async {
    if (mapController == null) return;

    final cameraPosition = await mapController!.getCameraPosition();
    final zoom = cameraPosition.zoom;

    await mapController!.moveCamera(
      CameraUpdate.zoomTo(zoom + 1),
      animation:
          const MapAnimation(type: MapAnimationType.linear, duration: 0.3),
    );
  }

  Future<void> _zoomOut() async {
    if (mapController == null) return;

    final cameraPosition = await mapController!.getCameraPosition();
    final zoom = cameraPosition.zoom;

    await mapController!.moveCamera(
      CameraUpdate.zoomTo(zoom - 1),
      animation:
          const MapAnimation(type: MapAnimationType.linear, duration: 0.3),
    );
  }

  List<Vacancy> _filterVacanciesInRadius() {
    if (currentCenter == null) return [];

    return widget.vacancies.where((vacancy) {
      if (vacancy.latitude == null || vacancy.longitude == null) return false;

      final vacancyPoint = Point(
        latitude: vacancy.latitude!,
        longitude: vacancy.longitude!,
      );

      final distance = _calculateDistance(currentCenter!, vacancyPoint);
      return distance <= currentRadius;
    }).toList();
  }

  double _calculateDistance(Point p1, Point p2) {
    const earthRadius = 6371000;
    final lat1 = p1.latitude * (math.pi / 180);
    final lon1 = p1.longitude * (math.pi / 180);
    final lat2 = p2.latitude * (math.pi / 180);
    final lon2 = p2.longitude * (math.pi / 180);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  void _updateMapObjects() {
    final objects = <MapObject>[];

    objects.add(CircleMapObject(
      mapId: const MapObjectId('radius_circle'),
      circle: Circle(
        center: currentCenter!,
        radius: currentRadius,
      ),
      strokeColor: Colors.green.withOpacity(0.5),
      strokeWidth: 2,
      fillColor: Colors.green.withOpacity(0.2),
      zIndex: 1,
    ));

    for (var i = 0; i < filteredVacancies.length; i++) {
      final vacancy = filteredVacancies[i];
      if (vacancy.latitude == null || vacancy.longitude == null) continue;

      objects.add(PlacemarkMapObject(
        mapId: MapObjectId('vacancy_${vacancy.id}'),
        point: Point(
          latitude: vacancy.latitude!,
          longitude: vacancy.longitude!,
        ),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image:
                BitmapDescriptor.fromAssetImage('assets/images/map_marker.png'),
            scale: 1.0,
          ),
        ),
        opacity: 1.0,
        onTap: (_, __) => _showVacancyInfo(vacancy),
      ));
    }

    setState(() {
      mapObjects.clear();
      mapObjects.addAll(objects);
    });
  }

  void _showVacancyInfo(Vacancy vacancy) {
    if (_isModalOpen) return;
    _isModalOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vacancy.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (vacancy.minSalary != null ||
                                vacancy.maxSalary != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${vacancy.minSalary?.toString() ?? ''} – ${vacancy.maxSalary?.toString() ?? ''} ₽ за месяц'
                                      .replaceAll(' – ', '–')
                                      .replaceAll('– ', ''),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            if (vacancy.locationCity != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${vacancy.locationCity!.name} (${vacancy.locationCity!.region?.name ?? ''})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            if (vacancy.agencyName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      vacancy.agencyName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified,
                                        color: Colors.blue, size: 16),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Опубликовано ${DateFormat('dd MMMM', 'ru_RU').format(vacancy.publishedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const Divider(),
                            if (vacancy.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  vacancy.description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _openYandexMaps(vacancy);
                        },
                        child: const Text(
                          'Продолжить маршрут',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _isModalOpen = false;
    });
  }

  Future<void> _openYandexMaps(Vacancy vacancy) async {
    if (vacancy.latitude == null || vacancy.longitude == null) return;

    final url = Uri.parse(
        'yandexmaps://maps.yandex.ru/?pt=${vacancy.longitude},${vacancy.latitude}&z=15');
    final fallbackUrl = Uri.parse(
        'https://yandex.ru/maps/?pt=${vacancy.longitude},${vacancy.latitude}&z=15');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl);
      } else {
        throw 'Не удалось открыть Яндекс Карты';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _moveToLocation(Point point) async {
    if (mapController == null) return;

    await mapController!.moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point,
          zoom: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Вакансии на карте'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text('Радиус: '),
                    Expanded(
                      child: Slider(
                        value: currentRadius,
                        min: 500,
                        max: 5000,
                        divisions: 9,
                        label:
                            '${(currentRadius / 1000).toStringAsFixed(1)} км',
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey[300],
                        onChanged: (value) {
                          setState(() {
                            currentRadius = value;
                            filteredVacancies = _filterVacanciesInRadius();
                            _updateMapObjects();
                          });
                        },
                      ),
                    ),
                    Text('${(currentRadius / 1000).toStringAsFixed(1)} км'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Найдено вакансий: ${filteredVacancies.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (currentCenter != null)
                      TextButton(
                        onPressed: () => _moveToLocation(currentCenter!),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                        child: const Text('Центрировать'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: YandexMap(
                  onMapCreated: (controller) async {
                    mapController = controller;
                    if (currentCenter != null) {
                      await _moveToLocation(currentCenter!);
                      _updateMapObjects();
                    }
                  },
                  onCameraPositionChanged:
                      (cameraPosition, reason, inProgress) {
                    if (!inProgress) {
                      final double minDistanceToUpdate = 50;
                      if (currentCenter == null ||
                          _calculateDistance(
                                  currentCenter!, cameraPosition.target) >
                              minDistanceToUpdate) {
                        setState(() {
                          currentCenter = cameraPosition.target;
                          filteredVacancies = _filterVacanciesInRadius();
                          _updateMapObjects();
                        });
                      }
                    }
                  },
                  mapObjects: mapObjects,
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'location',
                  onPressed: _determinePosition,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.green),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_in',
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.green),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoom_out',
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.green),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
