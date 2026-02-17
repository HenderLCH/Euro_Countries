import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:path_provider/path_provider.dart';

class RestCountriesApi {
  late final Dio _dio;
  late final CacheStore _cacheStore;

  RestCountriesApi() {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    final dir = await getTemporaryDirectory();
    _cacheStore = DbCacheStore(databasePath: dir.path);

    final cacheOptions = CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.forceCache,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 7),
      priority: CachePriority.high,
      keyBuilder: (request) => request.uri.toString(),
    );

    _dio = Dio(BaseOptions(
      baseUrl: 'https://restcountries.com/v3.1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ))
      ..interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  Future<List<dynamic>> getEuropeanCountries() async {
    final response = await _dio.get('/region/europe');
    return response.data as List<dynamic>;
  }

  // Usa /name/{name} NO /translation/{nombre}
  Future<dynamic> getCountryByName(String name) async {
    final response = await _dio.get('/name/$name');
    final data = response.data as List<dynamic>;
    return data.first;
  }

  void dispose() {
    _cacheStore.close();
    _dio.close();
  }
}
