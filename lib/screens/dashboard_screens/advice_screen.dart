import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/main_back_button_widget.dart';

class AdviceScreen extends StatefulWidget {
  @override
  _AdvicesScreenState createState() => _AdvicesScreenState();
}

class _AdvicesScreenState extends State<AdviceScreen> {
  // Podaci iz API-ja
  double kwhConsumption = 0;
  double totalDueElectricity = 0;
  double previousDebtElectricity = 0;
  double waterConsumption = 0;
  double totalDueWater = 0;
  double lastInvoiceAmountWater = 0;

  List<bool> revealed = List.generate(6, (index) => false);
  List<String> tips = ["Učitavanje saveta..."];

  Future<void> fetchData() async {
    final responseElectricity = await http.get(Uri.parse(
        'https://lukamasulovic.site/epcg?pretplatniBroj=152577011&brojBrojila=18N4E5B2514906007'));

    if (responseElectricity.statusCode == 200) {
      var data = json.decode(responseElectricity.body);
      setState(() {
        kwhConsumption =
            double.tryParse(data['poslednji_racun']['iznos'].toString()) ?? 0;
        totalDueElectricity =
            double.tryParse(data['ukupno_za_uplatu'].toString()) ?? 0;
        previousDebtElectricity =
            double.tryParse(data['prethodni_dug'].toString()) ?? 0;
      });
    }

    final responseWater = await http.get(Uri.parse(
        'https://lukamasulovic.site/vodovod_niksic?pretplatniBroj=222210'));

    if (responseWater.statusCode == 200) {
      var data = json.decode(responseWater.body);
      setState(() {
        waterConsumption = double.tryParse(data['zaduzenje'].toString()) ?? 0;
        totalDueWater =
            double.tryParse(data['poslednji_racun'].toString()) ?? 0;
        lastInvoiceAmountWater =
            double.tryParse(data['poslednji_racun'].toString()) ?? 0;
      });
    }

    generateAdvice();
  }

  void generateAdvice() {
    List<String> newTips = [];

    if (kwhConsumption > 500) {
      newTips.add(
          "Vaša potrošnja struje je visoka! Razmislite o štednji energije.");
    }
    if (totalDueElectricity > 100) {
      newTips.add(
          "Vaš dug za struju je značajan. Razmislite o delimičnom plaćanju.");
    }
    if (previousDebtElectricity > 50) {
      newTips.add(
          "Imate prethodni dug za struju. Plaćanjem na vreme izbegavate dodatne troškove.");
    }
    if (waterConsumption > 10) {
      newTips.add(
          "Vaša potrošnja vode je visoka! Pokušajte da smanjite nepotrebno korišćenje.");
    }
    if (totalDueWater > 20) {
      newTips.add(
          "Vaš poslednji račun za vodu je visok! Proverite da li ima curenja.");
    }

    if (newTips.isEmpty) {
      newTips
          .add("Odlično! Vaša potrošnja struje i vode je u granicama normale.");
    }

    setState(() {
      tips = newTips;
      revealed = List.generate(tips.length, (index) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
                    const SizedBox(height: 10),
                    const Text(
                      'Savjeti',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGrid(),
                  ],
                ),
              ),
            ],
          ),
          MainBackButtonWidget(size: 38, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.4,
        ),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                revealed[index] = !revealed[index];
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
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
              child: Center(
                child: revealed[index]
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          tips[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Icon(
                        Icons.lightbulb_outline,
                        size: 40,
                        color: Color(0xFF1B5E20),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
