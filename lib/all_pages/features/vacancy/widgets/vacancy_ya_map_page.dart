import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:url_launcher/url_launcher.dart'; // Добавьте этот пакет в pubspec.yaml

class MapScreen extends StatefulWidget {
  final String vacancyTitle;
  final String address;
  final double? latitude;
  final double? longitude;

  const MapScreen({
    super.key,
    required this.vacancyTitle,
    required this.address,
    this.latitude,
    this.longitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  YandexMapController? mapController;
  final List<MapObject> mapObjects = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    mapController?.dispose();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7),
      systemNavigationBarDividerColor: Colors.transparent,
    ));
    super.dispose();
  }

  Future<void> _openYandexMaps() async {
    if (widget.latitude == null || widget.longitude == null) return;

    final url = Uri.parse(
        'yandexmaps://maps.yandex.ru/?pt=${widget.longitude},${widget.latitude}&z=15');
    final fallbackUrl = Uri.parse(
        'https://yandex.ru/maps/?pt=${widget.longitude},${widget.latitude}&z=15');

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

  Future<void> _openGoogleMaps() async {
    if (widget.latitude == null || widget.longitude == null) return;

    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}');
    final nativeUrl = Uri.parse(
        'comgooglemaps://?q=${widget.latitude},${widget.longitude}');

    try {
      // Пробуем открыть в приложении Google Maps
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl);
      }
      // Если приложения нет, открываем в браузере
      else if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Не удалось открыть Google Maps';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vacancyTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.map_pin_ellipse, color: Colors.red),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Проложить маршрут',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Image.asset(
                            'assets/images/google_icon.png',
                            width: 24,
                            height: 24,
                          ),
                          title: const Text('Карты'),
                          onTap: () {
                            _openGoogleMaps();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Image.asset(
                            'assets/images/yandex_icon.png',
                            width: 24,
                            height: 24,
                          ),
                          title: const Text('Яндекс Карты'),
                          onTap: () {
                            _openYandexMaps();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Адрес',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.address,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: YandexMap(
              onMapCreated: (controller) async {
                mapController = controller;
                if (widget.latitude != null && widget.longitude != null) {
                  await _moveToLocation();
                  _addPlacemark();
                }
              },
              mapObjects: mapObjects,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToLocation() async {
    if (mapController == null) return;

    await mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: widget.latitude ?? 0,
            longitude: widget.longitude ?? 0,
          ),
          zoom: 15,
        ),
      ),
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
    );
  }

  void _addPlacemark() {
    final placemark = PlacemarkMapObject(
      mapId: const MapObjectId('placemark_1'),
      point: Point(
        latitude: widget.latitude ?? 0,
        longitude: widget.longitude ?? 0,
      ),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/images/map_marker.png'),
          scale: 1.0,
        ),
      ),
      opacity: 1.0,
      isDraggable: false,
      direction: 0,
      onTap: (PlacemarkMapObject self, Point point) {
        // Обработка клика по метке
      },
    );

    setState(() {
      mapObjects.clear();
      mapObjects.add(placemark);
    });
  }


}