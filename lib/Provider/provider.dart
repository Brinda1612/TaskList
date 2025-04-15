import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Models/task_model.dart';

class TaskProvider extends ChangeNotifier{

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  final _id = Uuid();

  TaskProvider(){

  }

  Future<void> loadTask() async{
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString("task_list");
    if(data != null){
      final List list = jsonDecode(data);
      _tasks = list.map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveTask() async{

    final pref = await SharedPreferences.getInstance();
    final data = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    pref.setString("task_list", data);
    notifyListeners();
  }

  void addTask(String title, String des) async{
    final task = Task(id: _id.v4(), title: title, description: des);
    _tasks.add(task);
    await saveTask();
    notifyListeners();
  }

  void delete(String id){
    _tasks.removeWhere((e) => e.id == id);
    saveTask();
    notifyListeners();
  }

  void updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await saveTask();
      notifyListeners();
    }
  }


}