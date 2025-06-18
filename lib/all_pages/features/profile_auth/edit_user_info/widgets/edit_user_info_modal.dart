import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/features/vacancy_filter/widgets/city_search_modal.dart';
import 'package:provider/provider.dart';
import 'package:gr_jobs/all_pages/service/provider.dart';
import 'package:gr_jobs/all_pages/models_supabase/user_model.dart';
import 'package:gr_jobs/all_pages/models_supabase/city_model.dart';
import 'package:gr_jobs/all_pages/service/vacancy_provider.dart';
import 'package:intl/intl.dart';

class EditProfileModal extends StatefulWidget {
  final User user;
  final List<City> cities;
  const EditProfileModal({Key? key, required this.user, required this.cities}) : super(key: key);

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController middleNameController;
  late TextEditingController birthDateController;
  late TextEditingController cityController;
  String? selectedGender = 'M';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    middleNameController = TextEditingController(text: widget.user.middleName);
    birthDateController = TextEditingController(
      text: widget.user.birthDate != null
          ? DateFormat('yyyy-MM-dd').format(widget.user.birthDate!)
          : '',
    );
    cityController = TextEditingController(text: widget.user.city.name);
    selectedGender = widget.user.gender;


  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
    birthDateController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _selectGender(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Пол',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Для балансировки
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption('Мужской', 'M'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGenderOption('Женский', 'F'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(String text, String value) {
    bool isSelected = selectedGender == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedGender = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.green : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.user.birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectCity(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => CitySearchModal(
        cities: widget.cities,
        initialCity: cityController.text,
      ),
    );
    if (result != null && result != cityController.text) {
      setState(() {
        cityController.text = result;
      });
    }
  }

  Future<void> _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final userProvider = AppProvider.user(context);
    try {
      final city = widget.cities.firstWhere(
            (c) => c.name == cityController.text,
        orElse: () => widget.user.city,
      );
      await userProvider.updateUser({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'middle_name': middleNameController.text,
        'birth_date': birthDateController.text.isNotEmpty
            ? birthDateController.text
            : null,
        'gender': selectedGender,
        'city_id': city.id,
      });
      if (mounted) {
        Navigator.pop(context, true); // Передаем true как признак успешного сохранения
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
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

            Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Редактирование профиля',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            const Divider(height: 1.0),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Основная информация',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- Фамилия ---
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Фамилия',
                          hintText: 'Введите фамилию',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          labelStyle: const TextStyle(color: Colors.grey), // Fix label color
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите фамилию';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // --- Имя ---
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Имя',
                          hintText: 'Введите имя',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          labelStyle: const TextStyle(color: Colors.grey), // Fix label color
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите имя';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // --- Отчество ---
                      TextFormField(
                        controller: middleNameController,
                        decoration: InputDecoration(
                          labelText: 'Отчество',
                          hintText: 'Введите отчество',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          labelStyle: const TextStyle(color: Colors.grey), // Fix label color
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- Пол ---
                      TextField(
                        controller: TextEditingController(text: selectedGender == 'M' ? 'Мужской' : 'Женский'),
                        decoration: InputDecoration(
                          labelText: 'Пол',
                          hintText: 'Выберите пол',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                          labelStyle: const TextStyle(color: Colors.grey), // Fix label color
                        ),
                        readOnly: true,
                        onTap: () => _selectGender(context),
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedGender != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- Дата рождения ---
                      TextField(
                        controller: birthDateController,
                        decoration: InputDecoration(
                          labelText: 'Дата рождения',
                          hintText: 'Выберите дату рождения',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          suffixIcon: const Icon(Icons.calendar_today, size: 16),
                          labelStyle: const TextStyle(color: Colors.grey), // Fix label color
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        style: TextStyle(
                          fontSize: 16,
                          color: birthDateController.text.isNotEmpty ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // --- Город проживания ---
                      TextField(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: 'Город проживания',
                          hintText: 'Выберите город',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                          labelStyle: const TextStyle(color: Colors.grey), // Fix label color
                        ),
                        readOnly: true,
                        onTap: () => _selectCity(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Кнопка "Сохранить" в нижней части формы
            const Divider(height: 1.0),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _saveChanges(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}