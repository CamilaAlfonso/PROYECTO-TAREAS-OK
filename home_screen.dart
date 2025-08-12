import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final bool isFirst = ModalRoute.of(context)?.isFirst ?? false;
    debugPrint('HomeScreen -> canPop: $canPop | isFirst: $isFirst');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        // mostramos manualmente el icono para forzar su visibilidad
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); // si hay historial, pop normal
            } else {
              // si no hay historial (es root), forzamos volver al login y limpiamos stack
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Pantalla de creación/listado de tareas',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Si ves "canPop: true" al inicio, el back funcionará con pop().',
            ),
          ],
        ),
      ),
    );
  }
}
