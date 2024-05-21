import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // Import the flutter/services.dart package
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';

List<CameraDescription> cameras = [];

Future<Map<String, dynamic>> sendImageToServer(String imagePath) async {
  final String apiUrl = "http://127.0.0.1:5000/infer";
  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var streamedResponse = await request.send().timeout(Duration(seconds: 30));
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send image to server: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending image to server: $e');
    throw Exception('Error sending image to server: $e');
  }
}





Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(const RatatouilleApp());
}

Future<Directory> getTemporaryDirectory() async {
  return Directory.systemTemp;
}
String join(String base, String path) {
  return base + Platform.pathSeparator + path;
}


class RatatouilleApp extends StatelessWidget {
  const RatatouilleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratatouille',
      theme: ThemeData(
        primaryColor: const Color(0xFF186996),
        fontFamily: 'RatatouilleFont',
      ),
      home: const LoginPage(),

    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFFF0D541),
      ),
      backgroundColor: const Color(0xFFF0D541),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = usernameController.text; // Get the entered username
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CookingPage(username: username)), // Pass the username to CookingPage
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

class CookingPage extends StatelessWidget {
  final String username;

  const CookingPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Ratatouille'),
        backgroundColor: const Color(0xFFF0D541),
      ),
      backgroundColor: const Color(0xFFF0D541),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello $username',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/rat.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IngredientsPage()),
                );
              },
              child: const Text('Let\'s Start Cooking'),
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

  SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFFF0D541),
      ),
      backgroundColor: const Color(0xFFF0D541),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveToExcel(usernameController.text, passwordController.text);
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('username', usernameController.text);
                prefs.setString('password', passwordController.text);
                usernameController.clear();
                passwordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign up successful!'),
                  ),
                );
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Already have an account? Login'),
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
    const filePath = 'documents\\usernames.xlsx';
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
  }
}

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({Key? key}) : super(key: key);

  @override
  _IngredientsPageState createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  late CameraController _cameraController;
  final ImagePicker _picker = ImagePicker();
  Future<void>? _initializeCameraFuture;
  String? inferenceResult;

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();
    // Initialize all ingredients as unchecked
    for (String ingredient in ingredients) {
      checkedIngredients[ingredient] = false;
    }
  }

  List<String> ingredients = [
    // Herbs and Spices
    'Salt', 'Black pepper', 'Garlic powder', 'Onion powder', 'Paprika',
    'Cumin', 'Chili powder', 'Oregano', 'Basil', 'Thyme', 'Rosemary',
    'Parsley', 'Bay leaves', 'Curry powder', 'Cinnamon', 'Nutmeg', 'Ginger',
    'Turmeric', 'Cayenne pepper', 'Olive oil', 'Vegetable oil', 'Canola oil',
    'Coconut oil', 'Sesame oil', 'Balsamic vinegar', 'White vinegar',
    'Red wine vinegar', 'Apple cider vinegar', 'Rice vinegar', 'Ketchup',
    'Mustard', 'Mayonnaise', 'Soy sauce', 'Worcestershire sauce', 'Hot sauce',
    'Barbecue sauce', 'Sriracha', 'Hoisin sauce', 'Fish sauce', 'Tomato sauce/paste',
    'Rice', 'Pasta', 'Quinoa', 'Oats', 'Flour', 'Bread crumbs', 'Lentils',
    'Chickpeas', 'Black beans', 'Kidney beans', 'Cannellini beans', 'Diced tomatoes',
    'Tomato sauce', 'Tomato paste', 'Coconut milk', 'Broth', 'Milk', 'Butter',
    'Cheese', 'Yogurt', 'Cream cheese', 'Sour cream', 'Chicken', 'Beef', 'Pork',
    'Fish', 'Tofu', 'Eggs', 'Onions', 'Garlic', 'Potatoes', 'Carrots', 'Bell peppers',
    'Tomatoes', 'Lettuce', 'Spinach', 'Broccoli', 'Cauliflower', 'Zucchini',
    'Cucumbers', 'Avocados', 'Lemons', 'Limes', 'Apples', 'Bananas', 'Oranges',
    'Almonds', 'Walnuts', 'Pecans', 'Cashews', 'Peanuts', 'Sunflower seeds',
    'Chia seeds', 'Flaxseeds', 'Sesame seeds', 'Granulated sugar', 'Brown sugar',
    'Honey', 'Maple syrup', 'Agave syrup', 'Stevia', 'Powdered sugar', 'Baking powder',
    'Baking soda', 'Vanilla extract', 'Cocoa powder', 'Chocolate chips', 'Yeast',
    'Cornstarch', 'Molasses', 'Vinegar', 'Honey', 'Breadcrumbs', 'Stock cubes',
    'Bouillon', 'Gelatin', 'Cornmeal', 'Pickles',
  ];

  Map<String, bool> checkedIngredients = {};
  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        Map<String, dynamic> result = await sendImageToServer(image.path);
        setState(() {
          inferenceResult = result['predictions'][0]['class'];
        });
      } catch (e) {
        print('Error sending image to server: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Kitchen Ingredients'),
        backgroundColor: const Color(0xFFF0D541),
      ),
      backgroundColor: const Color(0xFFF0D541),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildIngredientGroup('Herbs and Spices', ingredients.sublist(0, 18)),
            _buildIngredientGroup('Cooking Oils', ingredients.sublist(18, 23)),
            _buildIngredientGroup('Vinegars', ingredients.sublist(23, 28)),
            _buildIngredientGroup('Condiments and Sauces', ingredients.sublist(28, 38)),
            _buildIngredientGroup('Grains and Cereals', ingredients.sublist(38, 44)),
            _buildIngredientGroup('Legumes', ingredients.sublist(44, 49)),
            _buildIngredientGroup('Canned Goods', ingredients.sublist(49, 54)),
            _buildIngredientGroup('Dairy and Non-dairy', ingredients.sublist(54, 60)),
            _buildIngredientGroup('Proteins', ingredients.sublist(60, 66)),
            _buildIngredientGroup('Fresh Produce', ingredients.sublist(66, 87)),
            _buildIngredientGroup('Nuts and Seeds', ingredients.sublist(87, 96)),
            _buildIngredientGroup('Sweeteners', ingredients.sublist(96, 103)),
            _buildIngredientGroup('Baking Ingredients', ingredients.sublist(103, 111)),
            _buildIngredientGroup('Miscellaneous', ingredients.sublist(111)),
            if (inferenceResult != null)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Inference Result: $inferenceResult'),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                List<String> selectedIngredients = [];
                for (String ingredient in checkedIngredients.keys) {
                  if (checkedIngredients[ingredient] == true) {
                    selectedIngredients.add(ingredient);
                  }
                }
                // Perform action with selectedIngredients, like navigating to a new page to display recipes
              },
              child: const Text('Generate Recipes'),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _pickImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientGroup(String title, List<String> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        CheckboxListTile(
          title: const Text("All"),
          value: checkedIngredients.values.every((value) => value),
          onChanged: (bool? value) {
            setState(() {
              for (var ingredient in ingredients) {
                checkedIngredients[ingredient] = value!;
              }
            });
          },
        ),
        ...ingredients.map((ingredient) {
          return CheckboxListTile(
            title: Text(ingredient),
            value: checkedIngredients[ingredient],
            onChanged: (bool? value) {
              setState(() {
                checkedIngredients[ingredient] = value!;
              });
            },
          );
        }).toList(),
      ],
    );
  }
}