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
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final senha = _passwordController.text.trim();
      final token = await fazerLogin(email, senha);

      if (token.isNotEmpty) {
        final tasks = await buscarTarefas(email, token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TodoApp(token: token, email: email, tasks: tasks)),
        );
      } else {
        setState(() {
          _errorMessage = 'Login falhou. Verifique suas credenciais.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login. Tente novamente mais tarde.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.black],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child:
                            Icon(Icons.person, size: 60, color: Colors.black),
                      ),
                      SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black54),
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        style: TextStyle(color: Colors.black87),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.black54),
                          prefixIcon: Icon(Icons.lock, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator.adaptive(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text('Entrar'),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Não tem uma conta?',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(width: 4),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text(
                              'Cadastre-se',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Crie sua conta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirme a Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Cadastrar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoApp extends StatelessWidget {
  final String token;
  final String email;
  final List<Task> tasks;

  TodoApp({required this.token, required this.email, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      home: TodoList(token: token, email: email, tasks: tasks),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoList extends StatefulWidget {
  final String token;
  final String email;
  final List<Task> tasks;

  TodoList({required this.token, required this.email, required this.tasks});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<Task> _tasks;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;
  }

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

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      text: json['titulo'],
      isCompleted: json['concluida'],
    );
  }
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

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 201) {
      print(
          'Erro ao salvar tarefas: ${response.statusCode} - ${response.body}');
    } else {
      print('Tarefas salvas com sucesso.');
    }
  } catch (e) {
    print('Erro: ${e.toString()}');
  }
}

Future<List<Task>> buscarTarefas(String email, String token) async {
  final url = Uri.https('barra.cos.ufrj.br:443', '/rest/tarefas');

  final headers = {
    'Authorization': 'Bearer $token',
    'accept': 'application/json',
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tasksJson =
          data.firstWhere((user) => user['email'] == email, orElse: () => null);

      if (tasksJson != null && (tasksJson['valor'] as List).isNotEmpty) {
        return (tasksJson['valor'] as List)
            .map((taskJson) => Task.fromJson(taskJson))
            .toList();
      } else {
        // Cria uma lista vazia se não houver tarefas
        await criarListaVazia(email, token);
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    print('Erro ao buscar tarefas: ${e.toString()}');
    return [];
  }
}

Future<void> criarListaVazia(String email, String token) async {
  final url = Uri.https('barra.cos.ufrj.br:443', '/rest/tarefas');

  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    'email': email,
    'valor': [], // Lista vazia
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201 || response.statusCode == 204) {
      print('Lista vazia criada com sucesso.');
    } else {
      print(
          'Erro ao criar lista vazia: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Erro ao criar lista vazia: ${e.toString()}');
  }
}
