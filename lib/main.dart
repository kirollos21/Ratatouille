import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart';
import 'dart:io';

void main() {
  runApp(RatatouilleApp());
}

class RatatouilleApp extends StatelessWidget {
  const RatatouilleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratatouille',
      theme: ThemeData(
        primaryColor: Color(0xFF186996),
        fontFamily: 'RatatouilleFont',
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFFF0D541),
      ),
      backgroundColor: Color(0xFFF0D541),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = usernameController.text; // Get the entered username
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CookingPage(username: username)), // Pass the username to CookingPage
                );
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

class CookingPage extends StatelessWidget {
  final String username;

  const CookingPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Ratatouille'),
        backgroundColor: Color(0xFFF0D541),
      ),
      backgroundColor: Color(0xFFF0D541),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello $username',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/rat.png',
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IngredientsPage()),
                );
              },
              child: Text('Let\'s Start Cooking'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xFFF0D541),
      ),
      backgroundColor: Color(0xFFF0D541),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveToExcel(usernameController.text, passwordController.text);
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('username', usernameController.text);
                prefs.setString('password', passwordController.text);
                usernameController.clear();
                passwordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sign up successful!'),
                  ),
                );
              },
              child: Text('Sign Up'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToExcel(String username, String password) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    int row = 1;
    while (sheet.cell(CellIndex.indexByString('A$row')).value != null) {
      row++;
    }
    sheet.cell(CellIndex.indexByString('A$row')).value = username as CellValue?;
    sheet.cell(CellIndex.indexByString('B$row')).value = password as CellValue?;
    final filePath = 'documents\\usernames.xlsx';
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final bytes = await excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
  }
}

class IngredientsPage extends StatefulWidget {
  @override
  _IngredientsPageState createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<String> ingredients = [
    'Tomato',
    'Cheese',
    'Chicken',
    'Meat',
  ];

  Map<String, bool> checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    // Initialize all ingredients as unchecked
    for (String ingredient in ingredients) {
      checkedIngredients[ingredient] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Kitchen Ingredients'),
        backgroundColor: Color(0xFFF0D541),
      ),
      backgroundColor: Color(0xFFF0D541),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (BuildContext context, int index) {
                String ingredient = ingredients[index];
                return CheckboxListTile(
                  title: Text(ingredient),
                  value: checkedIngredients[ingredient],
                  onChanged: (bool? value) {
                    setState(() {
                      checkedIngredients[ingredient] = value!;
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Action to search for recipes
              List<String> selectedIngredients = [];
              for (String ingredient in checkedIngredients.keys) {
                if (checkedIngredients[ingredient] == true) {
                  selectedIngredients.add(ingredient);
                }
              }
              // Perform action with selectedIngredients, like navigating to a new page to display recipes
            },
            child: Text('Search for Recipes'),
          ),
        ],
      ),
    );
  }
}