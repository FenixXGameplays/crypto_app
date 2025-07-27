import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../infrastucture/providers/providers.dart';

class CryptoDetailsPage extends StatefulWidget {
  final String cryptoId;

  const CryptoDetailsPage({super.key, required this.cryptoId});

  @override
  State<CryptoDetailsPage> createState() => _CryptoDetailsPageState();
}

class _CryptoDetailsPageState extends State<CryptoDetailsPage> {
  String selectedInterval = '1d'; // valores: 1d, 7d, 30d
  late Future<List<FlSpot>> _chartDataFuture;

  @override
  void initState() {
    super.initState();
    _chartDataFuture = _fetchData();
  }

  Future<List<FlSpot>> _fetchData() {
    return Provider.of<CryptoProvider>(context, listen: false)
        .fetchHistoricalData(widget.cryptoId, selectedInterval);
  }

  void _changeInterval(String interval) {
    setState(() {
      selectedInterval = interval;
      _chartDataFuture = _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cryptoProvider = Provider.of<CryptoProvider>(context);
    final crypto = cryptoProvider.cryptoList.firstWhere(
        (e) => e.name.toLowerCase() == widget.cryptoId.toLowerCase(),);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cryptoId.toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (crypto != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _CryptoStats(crypto: crypto),
            ),
          ],
          _IntervalSelector(
            selected: selectedInterval,
            onChanged: _changeInterval,
          ),
          Expanded(
            child: FutureBuilder(
              future: _chartDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final data = snapshot.data!;
                  return data.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: _ShowGraphPrices(data: data),
                        )
                      : const Center(
                          child: Text(
                            "No hay datos para mostrar",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CryptoStats extends StatelessWidget {
  final dynamic crypto;

  const _CryptoStats({required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '\$${crypto.price.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(title: '24h %', value: '${crypto.percentChange24h.toStringAsFixed(2)}%', color: crypto.percentChange24h >= 0 ? Colors.green : Colors.red),
            _StatItem(title: 'Volumen', value: '\$${(crypto.volume24h ?? 0).toStringAsFixed(0)}'),
            _StatItem(title: 'Market Cap', value: '\$${(crypto.marketCap ?? 0).toStringAsFixed(0)}'),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const _StatItem({required this.title, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color ?? Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

class _IntervalSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const _IntervalSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final intervals = {'1d': '24h', '7d': '7 días', '30d': '30 días'};

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: intervals.entries.map((e) {
        final isSelected = e.key == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ChoiceChip(
            label: Text(e.value),
            selected: isSelected,
            selectedColor: Colors.green,
            backgroundColor: Colors.grey[800],
            labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white),
            onSelected: (_) => onChanged(e.key),
          ),
        );
      }).toList(),
    );
  }
}

class _ShowGraphPrices extends StatelessWidget {
  final List<FlSpot> data;

  const _ShowGraphPrices({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxPrice = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minPrice = data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final isUpward = data.last.y >= data.first.y;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: data.length.toDouble(),
        minY: minPrice * 0.95,
        maxY: maxPrice * 1.05,
        gridData: FlGridData(
          show: true,
          horizontalInterval: (maxPrice - minPrice) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withOpacity(0.05),
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 50,
              showTitles: true,
              getTitlesWidget: (value, _) {
                return Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            gradient: LinearGradient(
              colors: isUpward
                  ? [Colors.greenAccent, Colors.green.shade800]
                  : [Colors.redAccent, Colors.red.shade800],
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: isUpward
                    ? [
                        Colors.greenAccent.withOpacity(0.3),
                        Colors.transparent
                      ]
                    : [
                        Colors.redAccent.withOpacity(0.3),
                        Colors.transparent
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: const FlDotData(show: false),
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
