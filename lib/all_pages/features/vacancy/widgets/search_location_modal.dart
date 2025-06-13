  import 'package:flutter/material.dart';

  class LocationPicker extends StatelessWidget {
    final String currentLocation;
    final ValueChanged<String> onLocationSelected;

    const LocationPicker({
      super.key,
      required this.currentLocation,
      required this.onLocationSelected,
    });

    void _showRegionSelectionModal(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (context) => _buildRegionSelectionModal(context),
      );
    }

    Widget _buildRegionSelectionModal(BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Регион',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.gps_fixed),
                    onPressed: () {
                      // Логика определения региона автоматически
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Регион поиска...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16, height: 1.0),
                ),
              ),
              const SizedBox(height: 16),
              // Здесь можно добавить список городов/регионов
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text('Волжский'),
                      onTap: () {
                        onLocationSelected('Волжский');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('Волгоград'),
                      onTap: () {
                        onLocationSelected('Волгоград');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('Камышин'),
                      onTap: () {
                        onLocationSelected('Камышин');
                        Navigator.pop(context);
                      },
                    ),
                    // Добавь остальные регионы
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return InkWell(
        onTap: () => _showRegionSelectionModal(context),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              currentLocation,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }