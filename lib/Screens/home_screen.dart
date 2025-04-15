import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../Models/task_model.dart';
import '../Provider/provider.dart';


class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTask();

    });
  }


  void _addTask() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      _showError('Title and description cannot be empty');
      return;
    }
    Provider.of<TaskProvider>(context, listen: false).addTask(title, desc);

    _titleController.clear();
    _descController.clear();
  }

  void _deleteTask(String id) {
    Provider.of<TaskProvider>(context, listen: false).delete(id);

  }

  void _toggleComplete(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    // _saveTasks();
  }

  void _updateTask(BuildContext context, Task task) {
    _titleController.text = task.title;
    _descController.text = task.description;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController),
            TextField(controller: _descController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty ||
                  _descController.text.trim().isEmpty) {
                _showError('Title and description cannot be empty');
                return;
              }

              final updatedTask = Task(
                id: task.id,
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
              );

              Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);

              _titleController.clear();
              _descController.clear();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          )
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    var of = Provider.of<TaskProvider>(context);
    final tasks = of.tasks;

    return Scaffold(
        appBar: AppBar(title: const Text('Task Manager')),
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Task Title')),
                TextField(controller: _descController, decoration: const InputDecoration(hintText: 'Task Description')),

                SizedBox(height: 10,),
                ElevatedButton(onPressed: _addTask, child: const Text('Add Task', style: TextStyle(color: Colors.black),)),
              ]),
            ),

            tasks.isEmpty
                ? const Center(child: Text('No tasks'))
                : ListView.builder(
              itemCount: tasks.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title,
                      style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none)),
                  subtitle: Text(task.description),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => _toggleComplete(task),
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _updateTask(context,task),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTask(task.id),
                    ),
                  ]),
                );
              },
            ),

          ],
        )
    );
  }
}
