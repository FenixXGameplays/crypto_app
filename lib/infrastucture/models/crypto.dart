class Crypto {
  final int id;
  final String name;
  final String symbol;
  final int cmcRank;
  final double price;
  final double percentChange24h;
  final double percentChange7d;
  final double percentChange30d;
  final double marketCap;
  final double volume24h;
  final String lastUpdated;

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.cmcRank,
    required this.price,
    required this.percentChange24h,
    required this.percentChange7d,
    required this.percentChange30d,
    required this.marketCap,
    required this.volume24h,
    required this.lastUpdated,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      cmcRank: json['cmc_rank'],
      price: json['quote']['USD']['price'].toDouble(),
      percentChange24h: json['quote']['USD']['percent_change_24h'].toDouble(),
      percentChange7d: json['quote']['USD']['percent_change_7d'].toDouble(),
      percentChange30d: json['quote']['USD']['percent_change_30d'].toDouble(),
      marketCap: json['quote']['USD']['market_cap'].toDouble(),
      volume24h: json['quote']['USD']['volume_24h'].toDouble(),
      lastUpdated: json['last_updated'],
    );
  }
}
