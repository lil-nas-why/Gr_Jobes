import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:provider/provider.dart';


class CitySearchModal extends StatefulWidget {
  final List<City> cities;
  final String? initialCity;

  const CitySearchModal({Key? key, required this.cities, this.initialCity})
      : super(key: key);

  @override
  State<CitySearchModal> createState() => _CitySearchModalState();
}

class _CitySearchModalState extends State<CitySearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<City> _filteredCities = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    if (widget.initialCity != null && widget.initialCity != 'Все города') {
      _searchController.text = widget.initialCity!.split(' (')[0];
      _performSearch(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCities = widget.cities;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final filtered = widget.cities.where((city) =>
        city.name.toLowerCase().contains(query.toLowerCase())).toList();

    setState(() {
      _filteredCities = filtered;
      _isSearching = false;
    });
  }

  String _getRegionName(City city) {
    return city.region?.name ?? 'Не указано';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VacancyProvider>(context);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text('Выберите город',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Поиск по городу...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.green.shade600, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 12),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 16, height: 1.0),
                onChanged: _performSearch,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Все города'),
                    onTap: () {
                      Navigator.pop(context, 'Все города');
                    },
                  ),

                  if (_isSearching)
                    const Center(child: CircularProgressIndicator())
                  else if (_filteredCities.isNotEmpty)
                    ..._filteredCities.map((city) => ListTile(
                      title: Text('${city.name} (${_getRegionName(city)})'),
                      onTap: () {
                        Navigator.pop(context, '${city.name} (${_getRegionName(city)})');
                      },
                    ))
                  else if (_searchController.text.isNotEmpty && !_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Город не найден'),
                      )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}