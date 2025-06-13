import 'package:flutter/material.dart';
import 'package:gr_jobs/all_pages/widgets/auth_flow/auth_modal_phone.dart';
import 'package:gr_jobs/all_pages/widgets/auth_flow/auth_modal_email.dart';

void showAuthModal(BuildContext context) {
  showModalBottomSheet(

    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AuthModal();
    },
  );
}

class AuthModal extends StatefulWidget {
  @override
  _AuthModalState createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  int _currentPage = 0; // 0 - выбор метода, 1 - телефон, 2 - почта



  void _showPhoneAuth() {
    setState(() {
      _currentPage = 1;
    });
  }

  void _showEmailAuth() {
    setState(() {
      _currentPage = 2;
    });
  }

  void _goBack() {
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Основное окно выбора метода
        if (_currentPage == 0)
          FractionallySizedBox(
            heightFactor: 0.6,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Вход и регистрация',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Последний раз вы входили с помощью email или телефона',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  // Варианты входа
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final method = ['По телефону', 'По электронной почте', 'Другие способы'][index];
                      final icon = [Icons.phone, Icons.email, Icons.more_horiz][index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          child: ListTile(
                            title: Text(method),
                            trailing: Icon(icon),
                            onTap: () {
                              if (index == 0) {
                                _showPhoneAuth();
                              } else if (index == 1) {
                                _showEmailAuth();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Логика поиска сотрудников
                    },
                    child: Text(
                      'Найти сотрудников',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Пользуясь приложением, вы принимаете соглашение и политику',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

        // Окно входа по телефону
        if (_currentPage == 1)
          AuthPhonePage(
            onBack: _goBack,
            onClose: () => Navigator.of(context).pop(),
          ),

        // Окно входа по почте
        if (_currentPage == 2)
          AuthEmailPage(
            onBack: _goBack,
            onClose: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }
}
