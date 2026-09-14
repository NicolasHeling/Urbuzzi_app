import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class OfflineInterceptor extends Interceptor {
  final Connectivity _connectivity = Connectivity();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    
    // Se estiver sem internet e for uma requisição GET, tenta ler do cache
    if (connectivityResult.contains(ConnectivityResult.none) && options.method == 'GET') {
      final box = await Hive.openBox('api_cache');
      final cacheKey = options.uri.toString();
      
      if (box.containsKey(cacheKey)) {
        return handler.resolve(Response(
          requestOptions: options,
          data: box.get(cacheKey),
          statusCode: 200,
        ));
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Se a requisição GET deu certo, salva no cache
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      final box = await Hive.openBox('api_cache');
      final cacheKey = response.requestOptions.uri.toString();
      await box.put(cacheKey, response.data);
    }
    super.onResponse(response, handler);
  }
}
