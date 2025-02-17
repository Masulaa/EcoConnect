import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard_screens/water_consumption_screen.dart';
import 'dashboard_screens/power_consumption_screen.dart';
import 'dashboard_screens/advice_screen.dart';
import 'dashboard_screens/goals_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Uri googleMapsUri = Uri.parse(
      "https://www.google.com/maps/search/eko+reciklazni+centri+crna+gora/");

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/logo.png', height: 60),
                const SizedBox(height: 10),
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20),
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 40),
                _buildSlidingContent(),
                const SizedBox(height: 10),
                _buildPageIndicator(),
                const SizedBox(height: 40),
                _buildButtonGrid(context),
              ],
            ),
          ),

          Positioned(
            top: 30,
            right: 20,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.person, color: Colors.green, size: 28),
              onSelected: (String value) {
                if (value == 'profile') {
                  print("Navigating to profile...");
                } else if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingContent() {
    return Container(
      width: 297,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD3E0D4),
            Color(0xFFF8FAF8),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(91, 71, 188, 0.3),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildChartBox(),
                _buildGoogleMapsDummy(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBox() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 508, color: Color(0xCC1B5E20))]),
          BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: 591, color: Color(0xCC1B5E20))]),
          BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 72, color: Color(0xCC1B5E20))]),
        ],
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildGoogleMapsDummy() {
    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri);
        }
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/map.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Pritisnite mapu za prikaz dostupnih reciklažnih centara",
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIndicatorDot(0),
        const SizedBox(width: 10),
        _buildIndicatorDot(1),
      ],
    );
  }

  Widget _buildIndicatorDot(int index) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Color(0xFF1B5E20) : Colors.grey[400],
      ),
    );
  }

  Widget _buildButtonGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(context, 'Potrošnja vode', Icons.water_damage,
                  WaterConsumptionScreen()),
              _buildButton(context, 'Potrošnja struje',
                  Icons.electrical_services, PowerConsumptionScreen()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(context, 'Savjeti', Icons.lightbulb, AdviceScreen()),
              _buildButton(context, 'Ciljevi', Icons.flag, GoalsScreen()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: 143,
        height: 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(91, 71, 188, 0.3),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              Color(0xFFD3E0D4),
              Color(0xFFF8FAF8),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF1B5E20), size: 40),
            const SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
        return;
      }

      final apiUrl = 'https://lukamasulovic.site/api/logout';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izlogovani ste.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IntroScreen()),
        );
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: ${responseData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška u povezivanju sa serverom.')),
      );
    }
  }
}
