import 'package:flutter/material.dart';

class SearchModal extends StatefulWidget {
  final VoidCallback onSearch;
  final String initialQuery;

  const SearchModal({
    super.key,
    required this.onSearch,
    this.initialQuery = '',
  });

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  late TextEditingController _searchController;
  List<String> searchHistory = [
    'Flutter разработчик',
    'Python разработка',
    'Менеджер проектов',
    'Frontend разработчик',
    'Backend разработчик',
    'Аналитик данных',
    'Дизайнер интерфейсов',
    'Тестировщик ПО',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text('Поиск', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Должность, ключевые слова...',
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
                onChanged: (value) {
                  // Здесь можно добавить логику поиска по мере ввода
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (_searchController.text.isNotEmpty)
                    ..._buildSearchResults()
                  else
                    ..._buildSearchHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchHistory() {
    return searchHistory.map((item) => _buildSearchHistoryItem(item)).toList();
  }

  List<Widget> _buildSearchResults() {
    // Здесь можно добавить реальную логику поиска
    // Пока просто фильтруем историю по введенному тексту
    return searchHistory
        .where((item) => item.toLowerCase().contains(_searchController.text.toLowerCase()))
        .map((item) => _buildSearchHistoryItem(item))
        .toList();
  }

  Widget _buildSearchHistoryItem(String text) {
    return ListTile(
      leading: Icon(Icons.history, color: Colors.grey),
      title: Text(text),
      onTap: () {
        Navigator.pop(context, text); // Возвращаем выбранный текст
      },
    );
  }
}
