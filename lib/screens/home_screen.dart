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
import 'edit_profile_screen.dart';
import 'intro_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Uri googleMapsUri = Uri.parse(
      "https://www.google.com/maps/search/eko+reciklazni+centri+crna+gora/");

  int _currentPage = 0;

  double kwhConsumption = 0;
  double totalDueElectricity = 0;
  double previousDebtElectricity = 0;
  double waterConsumption = 0;
  double totalDueWater = 0;
  double lastInvoiceAmountWater = 0;

  bool hasData = false;
  String? epcgNaplatniBroj;
  String? epcgBrojBrojila;
  String? vodovodPretplatniBroj;

  List<String> tips = ["Učitavanje saveta..."];

  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final authToken = prefs.getString('auth_token');

    if (userId != null && authToken != null) {
      final response = await http.get(
        Uri.parse('https://lukamasulovic.site/api/users/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var user = data['data']['user'];

        setState(() {
          vodovodPretplatniBroj = user['vodovod_pretplatni_broj'];
          epcgNaplatniBroj = user['epcg_naplatni_broj'];
          epcgBrojBrojila = user['epcg_broj_brojila'];
        });

        if (epcgNaplatniBroj != null && epcgBrojBrojila != null && vodovodPretplatniBroj != null) {
          setState(() {
            hasData = true;
          });
          fetchData(epcgNaplatniBroj!, epcgBrojBrojila!, vodovodPretplatniBroj!);
        } else {
          setState(() {
            hasData = false;
          });
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } else {
      setState(() {
        hasData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchData(String pretplatniBroj, String brojBrojila, String vodovodPretplatniBroj) async {

    final responseElectricity = await http.get(Uri.parse('https://lukamasulovic.site/epcg?pretplatniBroj=$pretplatniBroj&brojBrojila=$brojBrojila'));

    if (responseElectricity.statusCode == 200) {
    var data = json.decode(responseElectricity.body);

    double parseAmount(String value) {
      return double.tryParse(value.replaceAll('€', '').trim()) ?? 0.0;
    }

      setState(() {
        kwhConsumption = parseAmount(data['poslednji_racun']['iznos'].toString());
        totalDueElectricity = parseAmount(data['ukupno_za_uplatu'].toString());
        previousDebtElectricity = parseAmount(data['prethodni_dug'].toString());
      });
    }

    final responseWater = await http.get(Uri.parse(
      'https://lukamasulovic.site/vodovod_niksic?pretplatniBroj=$vodovodPretplatniBroj'));

    if (responseWater.statusCode == 200) {
    var data = json.decode(responseWater.body);
    print(data);

    double parseAmount(String value) {
      return double.tryParse(value.replaceAll('€', '').trim()) ?? 0.0;
    }

    setState(() {
      waterConsumption = parseAmount(data['zaduzenje'].toString());
      totalDueWater = parseAmount(data['poslednji_racun'].toString());
      lastInvoiceAmountWater = parseAmount(data['poslednji_racun'].toString());
      });
    }
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    decorationColor: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 40),
                _buildSlidingContent(),
                const SizedBox(height: 10),
                _buildPageIndicator(),
                const SizedBox(height: 40),
                _buildButtonGrid(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 20,
          child: PopupMenuButton<String>(
            icon: Icon(Icons.account_box, color: Color(0xFF1B5E20), size: 38),
            onSelected: (String value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
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
              barRods: [
                BarChartRodData(
                  toY: waterConsumption,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: kwhConsumption,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: totalDueWater,
                  color: Color(0xCC1B5E20),
                )
              ],
            ),
          ],
          titlesData: FlTitlesData(
  show: true,
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      interval: 1, // Održava ravnomeran raspored
      reservedSize: 30, // Povećava prostor za tekst
      getTitlesWidget: (double value, TitleMeta meta) {
        TextStyle style = const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          color: Color(0xFF1B5E20),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Dodaje razmak između labela
          child: Transform.rotate(
            angle: -0.3, // Blago rotira tekst ako se preklapa
            child: Text(
              switch (value.toInt()) {
                0 => 'Ukup. dug. voda',
                1 => 'Dug struje.',
                2 => 'Dug voda',
                _ => '',
              },
              style: style,
            ),
          ),
        );
      },
    ),
  ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Color(0xFF1B5E20),
                    ),
                  );
                },
              ),
            ),
          ),
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
    // Ovo je Putinovo crveno dugme. Kada logout ne radi (Greska pri povezivanju sa serverom), uncommenct ove 2 linije kako bi izbrisale nevazeci token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
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
