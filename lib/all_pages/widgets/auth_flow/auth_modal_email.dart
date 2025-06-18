import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gr_jobs/main.dart';
import 'package:gr_jobs/all_pages/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart' as supabase;

class AuthEmailPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;

  const AuthEmailPage({
    Key? key,
    required this.onBack,
    required this.onClose,
  }) : super(key: key);

  @override
  _AuthEmailPageState createState() => _AuthEmailPageState();
}

class _AuthEmailPageState extends State<AuthEmailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true; // true - войти, false - зарегистрироваться
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _heightAnimation = Tween<double>(begin: 0.6, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;

      if (_isLogin) {
        // Вход
        final response = await client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null) {
          widget.onClose();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Вы успешно вошли!")),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainApp()),
                (route) => false,);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ошибка входа")),
          );
        }
      } else {
        // Регистрация
        final signUpResponse = await client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (signUpResponse.user == null) {
          throw Exception('Не удалось зарегистрировать пользователя');
        }

        final user = signUpResponse.user!;

        print("User ID: ${user.id}");
        print("User Email: ${user.email}");

        // Добавляем пользователя в таблицу users
        final insertResponse = await client.from('users').insert({
          'supabase_user_id': user.id,
          'email': user.email,
        }).execute();

        // Проверяем статус ответа
        if (insertResponse.status >= 400) {
          final errorMessage = insertResponse.body?.toString() ?? "Неизвестная ошибка";
          throw Exception("Ошибка при добавлении пользователя: $errorMessage");
        }

        widget.onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Вы зарегистрированы!")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainApp()),
              (route) => false,);
      }
    } catch (e) {
      print("Ошибка при регистрации: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return FractionallySizedBox(
          heightFactor: _heightAnimation.value,
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
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        _controller.reverse().then((_) => widget.onBack());
                      },
                    ),
                    Expanded(
                      child: Text(
                        _isLogin ? 'Вход по почте' : 'Регистрация',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Почта',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    labelText: 'Пароль',
                  ),
                ),
                SizedBox(height: 16),
                // Поле дата рождения — только при регистрации
                if (!_isLogin)
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? "Нет аккаунта? Зарегистрируйтесь"
                        : "Уже есть аккаунт? Войдите",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                        : Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on PostgrestResponse {
  get body => null;
}