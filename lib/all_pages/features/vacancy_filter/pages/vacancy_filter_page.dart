// filters_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gr_jobs/all_pages/features/vacancy_filter/widgets/city_search_modal.dart';
import 'package:gr_jobs/all_pages/features/vacancy_filter/widgets/filter_search_modal.dart';
import 'package:gr_jobs/all_pages/features/vacancy_filter/widgets/work_schedule_modal.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:gr_jobs/all_pages/widgets/navigations/navigation_provider.dart';

class FiltersModal extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const FiltersModal({super.key, this.initialFilters});

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _salaryController = TextEditingController();

  // Filter data
  String _searchQuery = '';
  bool _showSalary = false;
  String _selectedCurrency = 'Рубли';
  int? _salaryFrom;
  String? _selectedExperienceLevel;
  List<String> _selectedEmploymentTypes = [];
  List<String> _selectedWorkSchedules = [];
  String _selectedLocation = 'Волжский (Волгоградская область)';

  bool _showScheduleClearButton = false;
  bool _showSalaryClearButton = false;
  bool _showSearchClearButton = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
    ));

    _salaryController.addListener(_updateSalaryValue);

    _selectedLocation = 'Все города';

    if (widget.initialFilters != null) {
      _searchQuery = widget.initialFilters!['searchQuery'] ?? '';
      _showSalary = widget.initialFilters!['showSalary'] ?? false;
      _selectedCurrency = widget.initialFilters!['currency'] ?? 'Рубли';
      _salaryFrom = widget.initialFilters!['salaryFrom'];
      _selectedExperienceLevel = widget.initialFilters!['experienceLevel'];
      _selectedEmploymentTypes =
      List<String>.from(widget.initialFilters!['employmentTypes'] ?? []);
      _selectedWorkSchedules =
      List<String>.from(widget.initialFilters!['workSchedules'] ?? []);
      _selectedLocation = widget.initialFilters!['location'] ?? 'Все города';

      _showSearchClearButton = _searchQuery.isNotEmpty;
      _showSalaryClearButton = _salaryFrom != null;
      _showScheduleClearButton = _selectedWorkSchedules.isNotEmpty;
    }

    _loadFilterData();
  }



  Future<void> _loadFilterData() async {
    final provider = Provider.of<VacancyProvider>(context, listen: false);
    await provider.loadFilterData();
    setState(() => _isLoading = false);
  }

  void _updateSalaryValue() {
    final digits = _salaryController.text.replaceAll(' ', '');
    setState(() {
      _salaryFrom = int.tryParse(digits);
      _showSalaryClearButton = _salaryController.text.isNotEmpty;
    });
  }

  bool _areFiltersDefault() {
    return _searchQuery.isEmpty &&
        !_showSalary &&
        _selectedCurrency == 'Рубли' &&
        _salaryFrom == null &&
        _selectedExperienceLevel == null &&
        _selectedEmploymentTypes.isEmpty &&
        _selectedWorkSchedules.isEmpty &&
        _selectedLocation == 'Все города';

  }

  String _formatSalary(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }

  Widget _buildFilterSearchBar(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (context) => FilterSearchModal(initialQuery: _searchQuery),
        );

        if (result != null) {
          setState(() {
            _searchQuery = result;
            _showSearchClearButton = result.isNotEmpty;
          });
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _searchQuery.isEmpty
                      ? 'Должность, ключевые слова'
                      : _searchQuery,
                  style: TextStyle(
                    color: _searchQuery.isEmpty ? Colors.grey : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (_showSearchClearButton)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  key: ValueKey<bool>(_showSearchClearButton),
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _showSearchClearButton = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryField() {
    // Обновляем текст контроллера при изменении _salaryFrom
    if (_salaryFrom != null) {
      _salaryController.text = _formatSalary(_salaryFrom!);
    } else {
      _salaryController.clear();
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) return newValue;

                          // Удаляем все пробелы перед форматированием
                          final digits = newValue.text.replaceAll(' ', '');

                          // Форматируем число с пробелами
                          final formatted = digits.replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]} ',
                          );

                          // Обновляем контроллер
                          _salaryController.text = formatted;
                          _salaryController.selection = TextSelection.collapsed(
                            offset: formatted.length,
                          );

                          return TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                        }),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Уровень дохода от',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      cursorColor: Colors.transparent,
                      cursorWidth: 0,
                      cursorHeight: 0,
                      showCursor: false,
                      enableInteractiveSelection: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _selectedCurrency == 'Рубли'
                          ? '₽'
                          : _selectedCurrency == 'Доллары'
                          ? '\$'
                          : '€',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showSalaryClearButton)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                key: ValueKey<bool>(_showSalaryClearButton),
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () {
                  setState(() {
                    _salaryFrom = null;
                    _showSalaryClearButton = false;
                    _salaryController.clear();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOptions() {
    final List<String> currencies = ['Рубли', 'Доллары', 'Евро'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: currencies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final isSelected = _selectedCurrency == currency;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCurrency = currency;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  currency,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExperienceOptionsWidget() {
    final provider = Provider.of<VacancyProvider>(context);
    if (_isLoading) return const CircularProgressIndicator();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.experienceOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final experience = provider.experienceOptions[index];
          final isSelected = _selectedExperienceLevel == experience.name;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedExperienceLevel = experience.name;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  experience.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmploymentTypeOptionsWidget() {
    final provider = Provider.of<VacancyProvider>(context);
    if (_isLoading) return const CircularProgressIndicator();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.workFormats.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final format = provider.workFormats[index];
          final isSelected =
          _selectedEmploymentTypes.contains(format.formatName);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedEmploymentTypes.remove(format.formatName);
                } else {
                  _selectedEmploymentTypes.add(format.formatName);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  format.formatName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkScheduleFilterWidget() {
    return FractionallySizedBox(
      child: GestureDetector(
        onTap: () async {
          final result = await showModalBottomSheet<List<String>>(
            context: context,
            isScrollControlled: true,
            builder: (context) => WorkScheduleModal(
              selectedSchedules: _selectedWorkSchedules,
            ),
          );

          if (result != null) {
            setState(() {
              _selectedWorkSchedules = result;
              _showScheduleClearButton = result.isNotEmpty;
            });
          }
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _selectedWorkSchedules.isEmpty
                        ? 'График работы'
                        : _selectedWorkSchedules.join(', '),
                    style: TextStyle(
                      color: _selectedWorkSchedules.isEmpty
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (_showScheduleClearButton)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    key: ValueKey<bool>(_showScheduleClearButton),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedWorkSchedules.clear();
                        _showScheduleClearButton = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    final provider = Provider.of<VacancyProvider>(context);
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          builder: (context) => CitySearchModal(
            cities: provider.cities,
            initialCity: _selectedLocation,
          ),
        );

        if (result != null) {
          setState(() {
            _selectedLocation = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedLocation,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7)));

            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text('Фильтры'),
        actions: [
          TextButton(
            onPressed: _areFiltersDefault()
                ? null
                : () {
              setState(() {
                _searchQuery = '';
                _showSalary = false;
                _selectedCurrency = 'Рубли';
                _salaryFrom = null;
                _selectedExperienceLevel = null;
                _selectedEmploymentTypes.clear();
                _selectedWorkSchedules.clear();
                _selectedLocation = 'Все города'; // Сбрасываем город
                _showSalaryClearButton = false;
                _showSearchClearButton = false;
                _showScheduleClearButton = false;
              });
            },
            child: Text(
              'Сбросить',
              style: TextStyle(
                color: _areFiltersDefault() ? Colors.grey : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSearchBar(context),
                  const SizedBox(height: 16),
                  _buildSalaryField(),
                  const SizedBox(height: 8),
                  _buildCurrencyOptions(),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Указан доход'),
                    value: _showSalary,
                    onChanged: (value) => setState(() => _showSalary = value),
                  ),
                  const SizedBox(height: 16),
                  const Text('Требуемый опыт',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildExperienceOptionsWidget(),
                  const SizedBox(height: 16),
                  const Text('Тип занятости',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildEmploymentTypeOptionsWidget(),
                  const SizedBox(height: 16),
                  _buildWorkScheduleFilterWidget(),
                  const SizedBox(height: 16),
                  _buildLocationPicker(),
                ],
              ),
            ),
          ),

          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {

                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                    systemNavigationBarColor: Color.fromRGBO(0, 100, 0, 0.7)));

                final filters = {
                  'searchQuery': _searchQuery,
                  'showSalary': _showSalary,
                  'currency': _selectedCurrency,
                  'salaryFrom': _salaryFrom,
                  'experienceLevel': _selectedExperienceLevel,
                  'employmentTypes': _selectedEmploymentTypes,
                  'workSchedules': _selectedWorkSchedules,
                  'location': _selectedLocation,
                };

                final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                final vacancyProvider = Provider.of<VacancyProvider>(context, listen: false);

                navProvider.pushFilteredVacanciesPage(filters, context, vacancyProvider);
              },
              child: const Text(
                'Показать вакансии',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
