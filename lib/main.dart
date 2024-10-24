import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();
    final token = await fazerLogin(email, senha);

    if (token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TodoApp(token: token, email: email)),
      );
    } else {
      setState(() {
        _errorMessage = 'Login falhou. Verifique suas credenciais.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Não tem uma conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorMessage = '';

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'As senhas não coincidem.';
      });
      return;
    }

    final success = await registrarUsuario(name, email, phone, password);

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = 'Erro ao registrar. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Celular'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirme a Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Cadastrar'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class TodoApp extends StatelessWidget {
  final String token;
  final String email;

  TodoApp({required this.token, required this.email});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      home: TodoList(token: token, email: email),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoList extends StatefulWidget {
  final String token;
  final String email;

  TodoList({required this.token, required this.email});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask() {
    String taskText = _taskController.text.trim();

    bool taskExists = _tasks.any((task) => task.text == taskText);

    if (taskText.isNotEmpty && !taskExists) {
      setState(() {
        int insertIndex = _tasks.indexWhere((task) => task.isCompleted);
        if (insertIndex == -1) {
          _tasks.add(Task(text: taskText, isCompleted: false));
        } else {
          _tasks.insert(insertIndex, Task(text: taskText, isCompleted: false));
        }
      });
      _taskController.clear();
      _saveTasks();
    } else if (taskExists) {
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
        _saveTasks();
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
        int insertIndex = _tasks.indexWhere((task) => task.isCompleted);
        if (insertIndex == -1) {
          _tasks.add(toggledTask);
        } else {
          _tasks.insert(insertIndex, toggledTask);
        }
      } else {
        _tasks.insert(0, toggledTask);
      }
    });
    _saveTasks();
  }

  Future<void> _saveTasks() async {
    await salvarTarefas(widget.email, widget.token, _tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Tarefas',
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

class Task {
  String text;
  bool isCompleted;
  bool isPendingDelete;

  Task(
      {required this.text,
      required this.isCompleted,
      this.isPendingDelete = false});
}

Future<String> fazerLogin(String email, String senha) async {
  final url = Uri.https('barra.cos.ufrj.br:443', '/rest/rpc/fazer_login');

  final headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    'email': email,
    'senha': senha,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      return token;
    } else {
      return '';
    }
  } catch (e) {
    return '';
  }
}

Future<bool> registrarUsuario(
    String nome, String email, String celular, String senha) async {
  final url = Uri.https('barra.cos.ufrj.br:443', 'rest/rpc/registra_usuario');

  final headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    'nome': nome,
    'email': email,
    'celular': celular,
    'senha': senha,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      print('Erro ao registrar: ${errorData['message']}');
      return false;
    }
  } catch (e) {
    print('Erro: ${e.toString()}');
    return false;
  }
}

Future<void> salvarTarefas(String email, String token, List<Task> tasks) async {
  final url = Uri.https('barra.cos.ufrj.br:443', '/rest/tarefas');

  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    'email': email,
    'valor': tasks
        .map((task) => {
              'titulo': task.text,
              'concluida': task.isCompleted,
              'ordem': tasks.indexOf(task) + 1,
            })
        .toList(),
  });

  try {
    final response = await http.patch(url, headers: headers, body: body);

    if (response.statusCode != 200 && response.statusCode != 204) {
      print(
          'Erro ao salvar tarefas: ${response.statusCode} - ${response.body}');
    } else {
      print('Tarefas salvas com sucesso.');
    }
  } catch (e) {
    print('Erro: ${e.toString()}');
  }
}
