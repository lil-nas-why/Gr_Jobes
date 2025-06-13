import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/models_supabase/profession_model.dart';
import 'package:gr_jobs/all_pages/service/profession_service.dart';

import '../widgets/professions_search_modal.dart';

class ProfessionStep extends StatefulWidget {
  final Function(Profession) onProfessionSelected;
  final Profession? selectedProfession;

  const ProfessionStep({
    required this.onProfessionSelected,
    this.selectedProfession,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfessionStep> createState() => _ProfessionStepState();
}

class _ProfessionStepState extends State<ProfessionStep> {
  late final ProfessionService _professionService;
  List<Profession> _mainProfessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _professionService = ProfessionService();
    _loadMainProfessions();
  }

  Future<void> _loadMainProfessions() async {
    try {
      final professions = await _professionService.getMainProfessions();
      if (mounted) {
        setState(() {
          _mainProfessions = professions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openSearchModal() async {
    final Profession? result = await showModalBottomSheet<Profession>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProfessionSearchModal(
        onProfessionSelected: (profession) {
          Navigator.of(context).pop(profession);
        },
      ),
    );

    if (result != null && mounted) {
      widget.onProfessionSelected(result);
      // Не вызываем _nextStep() здесь, так как он уже вызывается в callback
    }
  }

  Future<void> _showSpecializations(Profession parentProfession) async {
    final specializations = await _professionService
        .getProfessionSpecializations(parentProfession.id);

    if (!mounted || specializations.isEmpty) return;

    final Profession? result = await showModalBottomSheet<Profession>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Text(
              'Выберите специализацию',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: specializations.length,
                itemBuilder: (context, index) {
                  final profession = specializations[index];
                  return ProfessionCard(
                    profession: profession.name,
                    isSelected: widget.selectedProfession?.id == profession.id,
                    onTap: () {
                      Navigator.of(context).pop(profession);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      widget.onProfessionSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Кем вы хотите работать?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SearchBar(onTap: _openSearchModal),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _mainProfessions.map((profession) {
                final isSelected = widget.selectedProfession?.id == profession.id;
                return ProfessionCard(
                  profession: profession.name,
                  isSelected: isSelected,
                  onTap: () => _showSpecializations(profession),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
class SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const SearchBar({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_outlined, size: 23, color: Colors.black54),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Поиск',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionCard extends StatelessWidget {
  final String profession;
  final bool isSelected;
  final VoidCallback onTap;

  const ProfessionCard({
    required this.profession,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green.shade600 : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              profession,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_outlined
                  : Icons.circle_outlined,
              color: isSelected ? Colors.green.shade600 : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}
