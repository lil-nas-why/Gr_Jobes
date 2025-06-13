import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';
import 'package:gr_jobs/all_pages/service/profession_service.dart';

class ProfessionSearchModal extends StatefulWidget {
  final Function(Profession) onProfessionSelected;

  const ProfessionSearchModal({
    required this.onProfessionSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfessionSearchModal> createState() => _ProfessionSearchModalState();
}

class _ProfessionSearchModalState extends State<ProfessionSearchModal> {
  late final ProfessionService _professionService;
  late TextEditingController _searchController;
  List<Profession> _searchResults = [];
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _professionService = ProfessionService();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (_isDisposed || query.isEmpty) {
      if (!_isDisposed) {
        setState(() => _searchResults = []);
      }
      return;
    }

    try {
      final results = await _professionService.searchProfessions(query);
      if (!_isDisposed) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() => _searchResults = []);
      }
    }
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
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: const Text(
                      'Поиск профессии',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Название профессии...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: Colors.green.shade600, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Начните вводить название профессии'
                      : 'Ничего не найдено',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final profession = _searchResults[index];
                  return ListTile(
                    title: Text(profession.name),
                    onTap: () {
                      widget.onProfessionSelected(profession);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}