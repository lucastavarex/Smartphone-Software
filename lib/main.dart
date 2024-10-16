import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(TodoApp());
}

class Task {
  String text;
  bool isCompleted;
  bool isPendingDelete;

  Task(
      {required this.text,
      required this.isCompleted,
      this.isPendingDelete = false});
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trabalho 3 - Lista de Tarefas',
      home: TodoList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    String taskText = _taskController.text.trim();

    // it will check if the task already exist
    bool taskExists = _tasks.any((task) => task.text == taskText);

    if (taskText.isNotEmpty && !taskExists) {
      setState(() {
        // find the position to insert the new task
        int insertIndex = _tasks.indexWhere((task) => task.isCompleted);
        if (insertIndex == -1) {
          _tasks.add(Task(text: taskText, isCompleted: false));
        } else {
          _tasks.insert(insertIndex, Task(text: taskText, isCompleted: false));
        }
      });
      _taskController.clear();
    } else if (taskExists) {
      // display a message if the task already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta tarefa já foi adicionada.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks[index].isPendingDelete = true;
    });
    Timer(Duration(seconds: 3), () {
      if (_tasks[index].isPendingDelete) {
        setState(() {
          _tasks.removeAt(index);
        });
      }
    });
  }

  void _undoDelete(int index) {
    setState(() {
      _tasks[index].isPendingDelete = false;
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      Task toggledTask = _tasks.removeAt(index);
      toggledTask.isCompleted = !toggledTask.isCompleted;
      if (toggledTask.isCompleted) {
        // find the position to insert the completed task
        int insertIndex = _tasks.indexWhere((task) => task.isCompleted);
        if (insertIndex == -1) {
          _tasks.add(toggledTask);
        } else {
          _tasks.insert(insertIndex, toggledTask);
        }
      } else {
        // insert the uncompleted task at the beginning of the list
        _tasks.insert(0, toggledTask);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '3° Trabalho - Lista de Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    onSubmitted: (_) => _addTask(),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Adicione a sua tarefa',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _addTask,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _toggleCompletion(index);
                    } else {
                      _deleteTask(index);
                    }
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: task.isPendingDelete
                          ? Colors.red
                          : (index % 2 == 0 ? Colors.grey[200] : Colors.white),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(blurRadius: 4.0, color: Colors.black26)
                      ],
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) => _toggleCompletion(index),
                        activeColor: Colors.black,
                      ),
                      title: Text(
                        task.text,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: task.isPendingDelete
                          ? TextButton(
                              onPressed: () => _undoDelete(index),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: Text(
                                'Desfazer',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteTask(index),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
