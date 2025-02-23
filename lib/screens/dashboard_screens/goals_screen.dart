import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/main_back_button_widget.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<TextEditingController> goalControllers = [];
  List<int> goalIds = [];
  bool isLoading = true;
  String? authToken;
  TextEditingController newGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGoals();
  }

  Future<void> fetchGoals() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('auth_token');

    if (authToken == null) {
      print('Auth token not found');
      return;
    }

    final response = await http.get(
      Uri.parse('https://lukamasulovic.site/api/goals/'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      List goals = json.decode(response.body);
      setState(() {
        goalControllers = goals
            .map((goal) => TextEditingController(text: goal['goal']))
            .toList();
        goalIds = goals.map<int>((goal) => goal['id'] as int).toList();
        isLoading = false;
      });
    } else {
      print('Failed to fetch goals: ${response.body}');
    }
  }

  Future<void> createGoal() async {
    String goalText = newGoalController.text;

    if (goalText.isEmpty || authToken == null) return;

    final response = await http.post(
      Uri.parse('https://lukamasulovic.site/api/goals'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'goal': goalText}),
    );

    if (response.statusCode == 201) {
      var newGoal = json.decode(response.body);
      setState(() {
        goalControllers.add(TextEditingController(text: newGoal['goal']));
        goalIds.add(newGoal['id']);
      });
      newGoalController.clear();
    } else {
      print('Failed to create goal: ${response.body}');
    }
  }

  Future<void> deleteGoal(int index) async {
    if (authToken == null) return;

    final response = await http.delete(
      Uri.parse('https://lukamasulovic.site/api/goals/${goalIds[index]}'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      setState(() {
        goalControllers.removeAt(index);
        goalIds.removeAt(index);
      });
    } else {
      print('Failed to delete goal: ${response.body}');
    }
  }

  Widget _styledTextField({required TextEditingController controller, String label = ""}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xCC1B5E20),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  Widget _styledButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xCC1B5E20),
        minimumSize: Size(MediaQuery.of(context).size.width * 0.6, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 60),
                    const SizedBox(height: 1),
                    const Text(
                      'Ciljevi',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: goalControllers.length + 1,
                        itemBuilder: (context, index) {
                          if (index == goalControllers.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  _styledTextField(controller: newGoalController, label: 'Unesite naziv cilja'),
                                  const SizedBox(height: 10),
                                  _styledButton(text: 'Dodaj novi cilj', onPressed: createGoal),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _styledTextField(controller: goalControllers[index]),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteGoal(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          MainBackButtonWidget(size: 38, color: Colors.black),
        ],
      ),
    );
  }
}
