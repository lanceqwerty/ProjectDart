import 'package:flutter/material.dart';

// Student model class
class Student {
  int id;
  String name;
  String email;

  Student({required this.id, required this.name, required this.email});

  // Convert to Map for potential future persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  // Create from Map
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}

void main() {
  runApp(StudentManagementApp());
}

class StudentManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StudentListScreen(),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> students = [];
  int _nextId = 1; // Auto-increment ID

  void _addStudent(Student student) {
    setState(() {
      students.add(student);
      _nextId++;
    });
  }

  void _updateStudent(int index, Student updatedStudent) {
    setState(() {
      students[index] = updatedStudent;
    });
  }

  void _deleteStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Records')),
      body: students.isEmpty
          ? Center(child: Text('No students yet. Add one!'))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student.name),
                  subtitle: Text(student.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _navigateToEditStudent(context, index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteStudent(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddStudent(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFormScreen(
          onSave: _addStudent,
          nextId: _nextId,
        ),
      ),
    );
  }

  void _navigateToEditStudent(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFormScreen(
          student: students[index],
          onSave: (updatedStudent) => _updateStudent(index, updatedStudent),
          nextId: _nextId,
        ),
      ),
    );
  }
}

class StudentFormScreen extends StatefulWidget {
  final Student? student; // Null for add, provided for edit
  final Function(Student) onSave;
  final int nextId;

  StudentFormScreen({this.student, required this.onSave, required this.nextId});

  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: widget.student?.id ?? widget.nextId,
        name: _nameController.text,
        email: _emailController.text,
      );
      widget.onSave(student);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStudent,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


