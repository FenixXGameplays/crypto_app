import 'package:crypto_app/presentation/screens/details_page/cryto_details_page.dart';
import 'package:crypto_app/presentation/screens/list_page/crypto_list_page.dart';
import 'package:go_router/go_router.dart';

final appRoute = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => CryptoListPage(),
    ),

    GoRoute(path: '/details/:cryptoId',
    builder: (context, state) { 
      final cryptoId = state.pathParameters['cryptoId'] ?? 'no-crypto';
      return CryptoDetailsPage(cryptoId: cryptoId);}),
  ],
);
