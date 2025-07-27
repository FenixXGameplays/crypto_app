import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../infrastucture/providers/providers.dart';

class CryptoListPage extends StatefulWidget {
  @override
  _CryptoListPageState createState() => _CryptoListPageState();
}

class _CryptoListPageState extends State<CryptoListPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final cryptoProvider = Provider.of<CryptoProvider>(context, listen: false);
    cryptoProvider.fetchCryptoList();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      cryptoProvider.fetchCryptoList();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cryptoProvider = Provider.of<CryptoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto List', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: cryptoProvider.cryptoList.length,
        itemBuilder: (context, index) {
          final crypto = cryptoProvider.cryptoList[index];

          return GestureDetector(
            onTap: () {
              _timer?.cancel();
              context.push('/details/${crypto.name.toLowerCase()}');
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://s2.coinmarketcap.com/static/img/coins/64x64/${crypto.id}.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
                title: Text(
                  crypto.name,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  crypto.symbol.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${crypto.percentChange24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: crypto.percentChange24h >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${crypto.price.toStringAsFixed(crypto.price > 5 ? 2 : 6)}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
