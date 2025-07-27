import 'package:crypto_app/infrastucture/response/crypto_response.dart';
import 'package:crypto_app/secrets.dart';
import 'package:crypto_app/strings/strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';

class CryptoProvider with ChangeNotifier {
  final String _baseUrl = 'https://pro-api.coinmarketcap.com/v1';
  final String _baseUrl2 = 'https://api.coingecko.com/api/v3';
  
  List<Crypto> _cryptoList = [];
  Map<String, dynamic>? _cryptoDetails;
  bool _isLoading = false;

  List<Crypto> get cryptoList => _cryptoList;
  Map<String, dynamic>? get cryptoDetails => _cryptoDetails;
  bool get isLoading => _isLoading;

Future<void> fetchCryptoList() async {

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cryptocurrency/listings/latest?start=1&limit=100&convert=USD'),
        headers: {'X-CMC_PRO_API_KEY': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cryptoList = (data['data'] as List)
            .map((crypto) => Crypto.fromJson(crypto))
            .toList();
      } else {
        throw Exception('Failed to load crypto list');
      }
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }


  /*Future<List<FlSpot>> fetchHistoricalData(String symbol) async {
    final DateTime now = DateTime.now();
    final DateTime oneDayAgo = now.subtract(const Duration(days: 1));

    final int timeStart = oneDayAgo.millisecondsSinceEpoch ~/ 1000;  // Convertir a Unix timestamp
    final int timeEnd = now.millisecondsSinceEpoch ~/ 1000;

    final url = Uri.parse(
        '$_baseUrl/cryptocurrency/ohlcv/historical?symbol=$symbol&convert=USD&time_start=$timeStart&time_end=$timeEnd');

    try {
      final response = await http.get(
        url,
        headers: {
          'X-CMC_PRO_API_KEY': _apiKey,  // Asegúrate de que este encabezado esté presente
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ohlcvData = data['data']['quotes'];
        
        // Convertir los datos a una lista de FlSpot (X: timestamp, Y: precio)
        List<FlSpot> spots = ohlcvData.map((item) {
          final timestamp = item['time'];
          final price = item['quote']['USD']['close'];
          return FlSpot(
            (timestamp - timeStart) / 3600,  // Convertir el timestamp a horas
            price.toDouble(),
          );
        }).toList();

        return spots;
      } else {
        throw Exception('Failed to load historical data');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }*/

Future<List<FlSpot>> fetchHistoricalData(String id, String interval) async {
  final now = DateTime.now();
  late DateTime from;

  // Determinar intervalo en función del parámetro
  switch (interval) {
    case '1d':
      from = now.subtract(const Duration(days: 1));
      break;
    case '7d':
      from = now.subtract(const Duration(days: 7));
      break;
    case '30d':
      from = now.subtract(const Duration(days: 30));
      break;
    default:
      from = now.subtract(const Duration(days: 1)); // fallback
  }

  final url = Uri.parse(
    '$_baseUrl2/coins/${id.toLowerCase().replaceAll(' ', '-')}/market_chart/range'
    '?vs_currency=usd'
    '&from=${from.millisecondsSinceEpoch ~/ 1000}'
    '&to=${now.millisecondsSinceEpoch ~/ 1000}',
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> prices = data['prices'];

      List<FlSpot> spots = prices.map((price) {
        final timestamp = price[0];
        final priceValue = price[1];
        return FlSpot(
          (timestamp - from.millisecondsSinceEpoch) / 3600000, // horas
          priceValue.toDouble(),
        );
      }).toList();

      return spots;
    } else {
      throw Exception('Failed to load historical data');
    }
  } catch (e) {
    print('Error fetching historical data: $e');
    return [];
  }
}

    
}
