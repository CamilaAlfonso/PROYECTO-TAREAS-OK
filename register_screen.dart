import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'tasks_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // -------- Validaciones --------
  bool _validatePassword(String password) {
    final re = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9]).{6,}$');
    return re.hasMatch(password);
  }

  bool _validateEmail(String email) {
    final re = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return re.hasMatch(email);
  }

  // -------- UI helpers --------
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Información'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // -------- Registro --------
  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Por favor completa todos los campos');
      return;
    }
    if (!_validatePassword(password)) {
      _showMessage(
        'La contraseña debe tener al menos 1 mayúscula, 1 número y 6 caracteres',
      );
      return;
    }
    if (!_validateEmail(email)) {
      _showMessage('Por favor ingresa un correo electrónico válido');
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await http.post(
        Uri.parse('http://10.0.2.2:3000/users'),
        headers: const {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      if (resp.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(resp.body);

        // Tomar id en las formas más comunes
        String? userId =
            (data['id'] ??
                    data['_id'] ??
                    data['user']?['id'] ??
                    data['data']?['id'])
                ?.toString();

        // Plan B: consultar por email si el backend no devolvió id en el POST
        if (userId == null || userId.isEmpty) {
          final get = await http.get(
            Uri.parse('http://10.0.2.2:3000/users?email=$email'),
          );
          if (get.statusCode == 200 && get.body.isNotEmpty) {
            final u = json.decode(get.body);
            userId =
                (u['id'] ?? u['_id'] ?? u['user']?['id'] ?? u['data']?['id'])
                    ?.toString();
          }
        }

        // if (userId == null || userId.isEmpty) {
        //   if (!mounted) return;
        //   _showMessage(
        //     'Registro exitoso, pero el backend no devolvió el ID del usuario. '
        //     'Haz que POST /users responda { id, name, email } o habilita GET /users?email=...',
        //   );
        //   return;
        // }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TasksScreen(userId: userId!)),
        );
      } else if (resp.statusCode == 409) {
        if (!mounted) return;
        _showMessage('El correo electrónico ya está registrado');
      } else {
        if (!mounted) return;
        _showMessage(
          'Error al crear el usuario. Código: ${resp.statusCode}\n${resp.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _registerUser,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
