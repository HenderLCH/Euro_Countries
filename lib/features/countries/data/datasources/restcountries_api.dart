import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:path_provider/path_provider.dart';


//API para obtener los paises europeos
class RestCountriesApi {
  late Dio _dio;
  late CacheStore _cacheStore;
  late Future<void> _initFuture;

  RestCountriesApi() {
    _initFuture = _initializeDio();
  }

  Future<void> _initializeDio() async {
    final dir = await getTemporaryDirectory();
    _cacheStore = DbCacheStore(databasePath: dir.path);

    //Configuracion de la cache
    
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

  Future<void> _ensureInitialized() async {
    await _initFuture;
  }

  //Metodo para obtener solamente los paises europeos

  Future<List<dynamic>> getEuropeanCountries() async {
    await _ensureInitialized();
    final response = await _dio.get('/region/europe');
    return response.data as List<dynamic>;
  }

  // Usa /name/{name} NO /translation/{nombre} para evitar multiples resultados
  //Metodo para obtener un pais por nombre
  Future<dynamic> getCountryByName(String name) async {
    await _ensureInitialized();
    final response = await _dio.get('/name/$name');
    final data = response.data as List<dynamic>;
    return data.first;
  }

  Future<void> dispose() async {
    await _ensureInitialized();
    _cacheStore.close();
    _dio.close();
  }
}
