import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TasksScreen extends StatefulWidget {
  final String userId;

  const TasksScreen({super.key, required this.userId});

  @override
  TasksScreenState createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  static const String _apiBase = 'http://10.0.2.2:3000';

  final _titleController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> tasks = [];
  String _selectedStatus = 'Pendiente';
  String _selectedPriority = 'Media';
  final listCtrl = ScrollController();

  final Map<String, Color> statusColors = {
    'Listo para empezar': const Color.fromARGB(255, 155, 249, 158),
    'En curso': const Color.fromARGB(255, 222, 183, 125),
    'Detenido': const Color.fromARGB(255, 232, 120, 112),
    'Pendiente': const Color.fromARGB(255, 239, 227, 126),
    'Terminado': const Color.fromARGB(255, 181, 163, 244),
  };
  final Map<String, Color> priorityColors = {
    'Alta': Colors.red,
    'Media': Colors.orange,
    'Baja': Colors.green,
    'Critica': Colors.purple,
    'Maximo esfuerzo': Colors.blueGrey,
  };

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void dispose() {
    listCtrl.dispose();
    _titleController.dispose();
    _startTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ===== API helpers =====
  Future<void> _fetchTasks() async {
    final uri = Uri.parse('$_apiBase/tasks?userId=${widget.userId}');
    try {
      final r = await http.get(uri);
      if (r.statusCode == 200) {
        final List data = json.decode(r.body) as List;
        setState(() {
          tasks
            ..clear()
            ..addAll(
              data.map<Map<String, dynamic>>(
                (e) => {
                  'id': e['id'],
                  'title': e['title'],
                  'description': e['description'],
                  'status': e['status'],
                  'priority': e['priority'],
                  'startTime': e['startTime'],
                },
              ),
            );
        });
      }
    } catch (e) {
      _showMessage('Error de conexión al cargar: $e');
    }
  }

  Future<http.Response> _postTask(Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$_apiBase/tasks'),
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode(body),
    );
  }

  Future<void> _deleteTask(String id) async {
    try {
      final r = await http.delete(Uri.parse('$_apiBase/tasks/$id'));
      if (r.statusCode == 204) {
        setState(() {
          tasks.removeWhere((t) => t['id'] == id);
        });
      } else {
        _showMessage('No se pudo eliminar (cód ${r.statusCode})');
      }
    } catch (e) {
      _showMessage('Error de conexión al eliminar: $e');
    }
  }

  Future<void> _updateTask(String id, Map<String, dynamic> patch) async {
    try {
      final r = await http.patch(
        Uri.parse('$_apiBase/tasks/$id'),
        headers: const {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(patch),
      );
      if (r.statusCode == 200) {
        final data = json.decode(r.body);
        setState(() {
          final i = tasks.indexWhere((t) => t['id'] == id);
          if (i != -1) {
            tasks[i] = {
              'id': data['id'],
              'title': data['title'],
              'description': data['description'],
              'status': data['status'],
              'priority': data['priority'],
              'startTime': data['startTime'],
            };
          }
        });
      } else {
        _showMessage('No se pudo actualizar (cód ${r.statusCode})');
      }
    } catch (e) {
      _showMessage('Error de conexión al actualizar: $e');
    }
  }

  // ===== Crear =====
  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final startTime = _startTimeController.text.trim();

    if (title.isEmpty || startTime.isEmpty) {
      _showMessage('Por favor ingresa el título y la hora de inicio');
      return;
    }

    final hhmm = RegExp(r'^[0-2]\d:[0-5]\d$');
    if (!hhmm.hasMatch(startTime)) {
      _showMessage('La hora debe ser HH:mm (ej. 08:05)');
      return;
    }

    final payload = {
      'title': title,
      'description': description,
      'status': _selectedStatus,
      'priority': _selectedPriority,
      'startTime': startTime,
      'totalHours': 0,
      'userId': widget.userId,
    };

    try {
      final response = await _postTask(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          tasks.insert(0, {
            'id': data['id'],
            'title': data['title'],
            'description': data['description'],
            'status': data['status'],
            'priority': data['priority'],
            'startTime': data['startTime'],
          });
        });
        _showMessage('Tarea creada exitosamente');
        _titleController.clear();
        _descriptionController.clear();
        _startTimeController.clear();
        setState(() {
          _selectedStatus = 'Pendiente';
          _selectedPriority = 'Media';
        });
      } else {
        _showMessage('Error al crear (cód ${response.statusCode})');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    }
  }

  // ===== UI helpers =====
  void _showMessage(String message) {
    if (!mounted) return;
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

  Color _getTaskStatusColor(String status) =>
      statusColors[status] ?? Colors.black12;
  Color _getTaskPriorityColor(String priority) =>
      priorityColors[priority] ?? Colors.black12;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      final hh = selectedTime.hour.toString().padLeft(2, '0');
      final mm = selectedTime.minute.toString().padLeft(2, '0');
      setState(() => _startTimeController.text = '$hh:$mm');
    }
  }

  void _openEditDialog(Map<String, dynamic> t) {
    final titleCtrl = TextEditingController(text: t['title']);
    final descriptionCtrl = TextEditingController(text: t['description']);
    final startTimeCtrl = TextEditingController(text: t['startTime'] ?? '');
    String status = t['status'];
    String priority = t['priority'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar tarea'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estado:'),
                  DropdownButton<String>(
                    value: status,
                    onChanged: (v) => status = v!,
                    items:
                        [
                              'Pendiente',
                              'En curso',
                              'Listo para empezar',
                              'Terminado',
                              'Detenido',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Prioridad:'),
                  DropdownButton<String>(
                    value: priority,
                    onChanged: (v) => priority = v!,
                    items:
                        ['Alta', 'Media', 'Baja', 'Critica', 'Maximo esfuerzo']
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                  ),
                ],
              ),
              TextField(
                controller: startTimeCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Hora (HH:mm)'),
                onTap: () async {
                  final tod = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (tod != null) {
                    final hh = tod.hour.toString().padLeft(2, '0');
                    final mm = tod.minute.toString().padLeft(2, '0');
                    startTimeCtrl.text = '$hh:$mm';
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateTask(t['id'], {
                'title': titleCtrl.text.trim(),
                'description': descriptionCtrl.text.trim(),
                'status': status,
                'priority': priority,
                'startTime': startTimeCtrl.text.trim(),
              });
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ===== Build =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Tareas')),
      body: RefreshIndicator(
        onRefresh: _fetchTasks,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // multilinea
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _startTimeController,
                decoration: const InputDecoration(
                  labelText: 'Hora de inicio (HH:mm)',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estado:'),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                    items:
                        [
                              'Pendiente',
                              'En curso',
                              'Listo para empezar',
                              'Terminado',
                              'Detenido',
                            ]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Prioridad:'),
                  DropdownButton<String>(
                    value: _selectedPriority,
                    onChanged: (v) => setState(() => _selectedPriority = v!),
                    items:
                        ['Alta', 'Media', 'Baja', 'Critica', 'Maximo esfuerzo']
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('Agregar Tarea'),
              ),
              Expanded(
                child: Scrollbar(
                  controller: listCtrl,
                  thumbVisibility: true,
                  interactive: true,
                  child: ListView.builder(
                    controller: listCtrl,
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final t = tasks[i];
                      return Card(
                        color: _getTaskStatusColor(
                          t['status']?.toString() ?? '',
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getTaskPriorityColor(
                                t['priority']?.toString() ?? '',
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(t['title']?.toString() ?? ''),
                          subtitle: Text(
                            'Estado: ${t['status']}  | Prioridad: ${t['priority']} | Hora: ${t['startTime'] ?? '--:--'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Información',
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Descripción'),
                                      content: Text(
                                        t['description']?.toString() ??
                                            'Sin descripción',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openEditDialog(t),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTask(t['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
