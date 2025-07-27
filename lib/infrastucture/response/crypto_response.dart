import '../models/crypto.dart';

class CryptoResponse {
  final List<Crypto> data;

  CryptoResponse({required this.data});

  factory CryptoResponse.fromJson(Map<String, dynamic> json) {
    return CryptoResponse(
      data: (json['data'] as List)
          .map((crypto) => Crypto.fromJson(crypto))
          .toList(),
    );
  }
}