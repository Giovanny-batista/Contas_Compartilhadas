import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GraficoPage extends StatefulWidget {
  @override
  _GraficoPageState createState() => _GraficoPageState();
}

class _GraficoPageState extends State<GraficoPage> {
  Map<String, double> categorizedExpenses = {'Variável': 00.0, 'Fixa': 00.0};
  bool isLoading = false;
  String errorMessage = '';
  String selectedMonth = DateFormat('MM/yyyy').format(DateTime.now());
  final colorList = <Color>[
    Colors.orange, 
    Colors.red,    
  ];

  @override
  void initState() {
    super.initState();
    _fetchDataForMonth(selectedMonth);
  }

  void _fetchDataForMonth(String monthYear) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final DateTime selectedDate = DateFormat('MM/yyyy').parse(monthYear);
      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('contas')
          .where('data', isGreaterThanOrEqualTo: startOfMonth)
          .where('data', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'Nenhuma despesa encontrada para $monthYear.';
          categorizedExpenses = {};
        });
        return;
      }

      Map<String, double> expenses = {'Variável': 10.0, 'Fixa': 80.0};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tipo = data['tipo'] as String?;
        final valor = data['valor'] as double?;

        if (tipo == null || valor == null) {
          continue;  
        }

        if (expenses.containsKey(tipo)) {
          expenses[tipo] = expenses[tipo]! + valor;
        } else {
          
        }
      }

      setState(() {
        categorizedExpenses = expenses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao buscar despesas: $e';
      });
    }
  }

  Map<String, double> _getDataMap() {
    return categorizedExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Despesas'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedMonth,
              items: _getMonthOptions().map((month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedMonth = value;
                  });
                  _fetchDataForMonth(value);
                }
              },
              isExpanded: true,
              iconSize: 30,
            ),
            SizedBox(height: 16),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(
                  child: Text(errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 16)))
            else
              Expanded(
                child: PieChart(
                  dataMap: _getDataMap(),
                  chartType: ChartType.ring,
                  colorList: colorList,
                  chartValuesOptions: ChartValuesOptions(
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: true,
                    decimalPlaces: 1,
                  ),
                  legendOptions: LegendOptions(
                    showLegends: true,
                    legendPosition: LegendPosition.left,
                    legendTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  animationDuration: Duration(seconds: 1),
                  ringStrokeWidth: 40,
                  centerText: 'Despesas',
                  centerTextStyle: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  baseChartColor: Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _getMonthOptions() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final monthDate = DateTime(now.year, now.month - index);
      return DateFormat('MM/yyyy').format(monthDate);
    }).toList();
  }
}
