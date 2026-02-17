# 🚀 Guía de Implementación - Prueba Técnica Flutter
## 📐 Arquitectura Feature-First

## 📋 Descripción de la Prueba Técnica

Desarrollar una aplicación Flutter que consuma la API pública de REST Countries para listar países europeos, mostrar detalles con caché inteligente, y gestionar una lista de deseos persistente.

### Requisitos Principales
- ✅ Listar países de Europa con tarjetas mostrando bandera e información relevante
- ✅ Página de detalles con caché (una petición por país)
- ✅ Lista de deseos persistente con Drift
- ✅ Prevención de janks al agregar múltiples países
- ✅ Gestión de estado con BLoC
- ✅ Pruebas unitarias para BLoC y base de datos

---

## 🛠️ Prerequisitos

Antes de comenzar, asegúrate de tener instalado:

```bash
# Verificar versiones
flutter --version  # >= 3.24.0
dart --version     # >= 3.5.3
git --version
```

### Instalaciones Necesarias
- **Flutter SDK 3.24+**: [Descargar aquí](https://docs.flutter.dev/get-started/install)
- **Dart SDK 3.5+**: Viene incluido con Flutter
- **Editor**: VS Code o Android Studio con extensiones de Flutter
- **Git**: Para control de versiones

---

## 📦 Paso 1: Crear el Proyecto Base

```bash
# Crear nuevo proyecto Flutter
flutter create euro_list
cd euro_list

# Verificar que el proyecto funciona
flutter run
```

---

## 🔧 Paso 2: Configurar Dependencies (pubspec.yaml)

Reemplaza el contenido de `pubspec.yaml` con:

```yaml
name: euro_list
description: "A Flutter application to explore European countries with wishlist functionality."
publish_to: 'none'
version: 1.0.0

environment:
  sdk: ^3.5.3
  flutter: ^3.24.0

dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & Caching
  dio: ^5.4.0
  dio_cache_interceptor: ^3.5.0
  dio_cache_interceptor_db_store: ^5.1.0
  
  # State Management
  flutter_bloc: ^8.1.3
  hydrated_bloc: ^9.1.5
  
  # Local Database
  drift: ^2.19.0
  sqlite3_flutter_libs: ^0.5.20
  path_provider: ^2.1.2
  path: ^1.9.0
  
  # UI & Utils
  cached_network_image: ^3.3.1
  flutter_svg: ^2.1.0
  url_launcher: ^6.2.4
  equatable: ^2.0.5
  get_it: ^7.6.7
  
  # Code Generation
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  very_good_analysis: ^5.1.0
  
  # Testing
  mocktail: ^1.0.3
  bloc_test: ^9.1.5
  drift_dev: ^2.19.0
  
  # Code Generation
  build_runner: ^2.4.8
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
```

**Instalar dependencias:**
```bash
flutter pub get
```

---

## 📁 Paso 3: Crear Estructura de Carpetas (Feature-First)

```bash
# Crear estructura completa por FEATURES (en Windows PowerShell)
$base = "lib"
$dirs = @(
    "$base\features\countries\domain\entities",
    "$base\features\countries\domain\repositories",
    "$base\features\countries\domain\usecases",
    "$base\features\countries\data\models",
    "$base\features\countries\data\datasources",
    "$base\features\countries\data\repositories",
    "$base\features\countries\presentation\bloc",
    "$base\features\countries\presentation\pages",
    "$base\features\countries\presentation\widgets",
    "$base\features\wishlist\domain\entities",
    "$base\features\wishlist\domain\repositories",
    "$base\features\wishlist\domain\usecases",
    "$base\features\wishlist\data\models",
    "$base\features\wishlist\data\datasources",
    "$base\features\wishlist\data\repositories",
    "$base\features\wishlist\presentation\bloc",
    "$base\features\wishlist\presentation\pages",
    "$base\features\wishlist\presentation\widgets",
    "$base\core\theme",
    "$base\core\utils",
    "$base\core\widgets"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# Crear carpetas de tests
mkdir test\features\countries, test\features\wishlist, test\core
mkdir assets\images
```

### 🎯 Nueva Estructura Feature-First:

```
lib/
├── features/                          🆕 Organización por features
│   ├── countries/                     # FEATURE: Gestión de países
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── country.dart
│   │   │   ├── repositories/
│   │   │   │   └── country_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_european_countries.dart
│   │   │       └── get_country_details.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── country_dto.dart
│   │   │   ├── datasources/
│   │   │   │   └── restcountries_api.dart
│   │   │   └── repositories/
│   │   │       └── countries_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── countries_cubit.dart
│   │       │   ├── countries_state.dart
│   │       │   ├── country_detail_cubit.dart
│   │       │   └── country_detail_state.dart
│   │       ├── pages/
│   │       │   ├── countries_page.dart
│   │       │   └── country_detail_page.dart
│   │       └── widgets/
│   │           ├── country_cart.dart
│   │           └── smart_flag_image.dart
│   │
│   └── wishlist/                      # FEATURE: Lista de deseos
│       ├── domain/
│       │   ├── entities/
│       │   │   └── wishlist_item.dart
│       │   ├── repositories/
│       │   │   └── wishlist_repository.dart
│       │   └── usecases/
│       │       ├── get_wishlist_items.dart
│       │       ├── add_to_wishlist.dart
│       │       ├── remove_from_wishlist.dart
│       │       ├── is_in_wishlist.dart
│       │       ├── batch_check_wishlist_status.dart
│       │       └── clear_wishlist_stress_test.dart
│       ├── data/
│       │   ├── models/
│       │   │   └── whislist_item_dto.dart
│       │   ├── datasources/
│       │   │   ├── app_database.dart
│       │   │   └── data_procesing_isolates.dart
│       │   └── repositories/
│       │       └── wishlist_repository_impl.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── wishlist_cubit.dart
│           │   └── wishlist_state.dart
│           ├── pages/
│           │   └── wishlist_page.dart
│           └── widgets/
│
├── core/                              # Código compartido
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── performance_monitor.dart
│   │   └── flag_perfomance_optimizer.dart
│   └── widgets/                       # Widgets compartidos
│       ├── error_widget.dart
│       └── loading_widget.dart
│
├── injection_container.dart           # Configuración GetIt
└── main.dart                          # Punto de entrada
```

---

## 🏗️ Paso 4: Implementar por Features (Orden Recomendado)

### 4.1 FEATURE COUNTRIES - CAPA DOMAIN

#### Crear Entidad (`features/countries/domain/entities/country.dart`)

```dart
import 'package:equatable/equatable.dart';

class Country extends Equatable {
  const Country({
    required this.id,
    required this.name,
    required this.capital,
    required this.population,
    required this.region,
    required this.flagUrl,
    this.currencies,
    this.languages,
    this.area,
    this.timezones,
  });

  final String id;
  final String name;
  final String capital;
  final int population;
  final String region;
  final String flagUrl;
  final String? currencies;
  final String? languages;
  final double? area;
  final String? timezones;

  @override
  List<Object?> get props => [
    id, name, capital, population, region, 
    flagUrl, currencies, languages, area, timezones,
  ];
}
```

#### Crear Repositorio (`features/countries/domain/repositories/country_repository.dart`)

```dart
import 'package:euro_list/features/countries/domain/entities/country.dart';

abstract class CountryRepository {
  Future<List<Country>> getEuropeanCountries();
  Future<Country> getCountryByName(String name);
}
```

#### Crear Use Cases (`features/countries/domain/usecases/`)

**`get_european_countries.dart`**:
```dart
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';

class GetEuropeanCountries {
  const GetEuropeanCountries({required this.repository});

  final CountryRepository repository;

  Future<List<Country>> call() async {
    return await repository.getEuropeanCountries();
  }
}
```

**`get_country_details.dart`**:
```dart
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';

class GetCountryDetails {
  const GetCountryDetails({required this.repository});

  final CountryRepository repository;

  Future<Country> call(String name) async {
    return await repository.getCountryByName(name);
  }
}
```

---

### 4.2 FEATURE WISHLIST - CAPA DOMAIN

#### Crear Entidad (`features/wishlist/domain/entities/wishlist_item.dart`)

```dart
import 'package:equatable/equatable.dart';

class WishlistItem extends Equatable {
  const WishlistItem({
    required this.id,
    required this.name,
    required this.flagUrl,
    required this.addedAt,
  });

  final String id;
  final String name;
  final String flagUrl;
  final DateTime addedAt;

  @override
  List<Object?> get props => [id, name, flagUrl, addedAt];
}
```

#### Crear Repositorio (`features/wishlist/domain/repositories/wishlist_repository.dart`)

```dart
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistRepository {
  Stream<WishlistChangeEvent> get wishlistChanges;
  Future<List<WishlistItem>> getWishlistItems();
  Future<void> addToWishlist(WishlistItem item);
  Future<void> removeFromWishlist(String countryId);
  Future<bool> isInWishlist(String countryId);
  Future<void> clearWishlist();
  Future<int> getWishlistCount();
  Future<Map<String, bool>> batchCheckWishlistStatus(List<String> countryIds);
  Future<void> addAllStressTest(List<WishlistItem> items);
}

enum WishlistChangeType { added, removed, cleared }

class WishlistChangeEvent {
  const WishlistChangeEvent({
    required this.type,
    required this.countryId,
  });

  final WishlistChangeType type;
  final String countryId;
}
```

#### Crear Use Cases (`features/wishlist/domain/usecases/`)

Puedes crear archivos separados o un solo archivo `manage_wishlist.dart` con todas las clases:

**Opción 1: Archivos separados (recomendado en feature-first)**

```dart
// add_to_wishlist.dart
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';

class AddToWishlist {
  const AddToWishlist({required this.repository});
  final WishlistRepository repository;

  Future<void> call(WishlistItem item) async {
    return await repository.addToWishlist(item);
  }
}
```

*Repite el patrón para:*
- `get_wishlist_items.dart`
- `remove_from_wishlist.dart`
- `is_in_wishlist.dart`
- `batch_check_wishlist_status.dart`
- `clear_wishlist_stress_test.dart`

---

### 4.3 FEATURE COUNTRIES - CAPA DATA

#### Crear Datasource (`features/countries/data/datasources/restcountries_api.dart`)

```dart
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
    ))..interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  Future<List<dynamic>> getEuropeanCountries() async {
    final response = await _dio.get('/region/europe');
    return response.data as List<dynamic>;
  }

  // ✅ CORRECTO: Usar /name/{name} NO /translation/{nombre}
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
```

#### Crear Modelo (`features/countries/data/models/country_dto.dart`)

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';

part 'country_dto.g.dart';

@JsonSerializable()
class CountryDto {
  @JsonKey(name: 'cca3')
  final String id;
  
  @JsonKey(name: 'name')
  final NameDto name;
  
  @JsonKey(name: 'capital')
  final List<String>? capital;
  
  @JsonKey(name: 'population')
  final int population;
  
  @JsonKey(name: 'region')
  final String region;
  
  @JsonKey(name: 'flags')
  final FlagsDto flags;
  
  @JsonKey(name: 'currencies')
  final Map<String, dynamic>? currencies;
  
  @JsonKey(name: 'languages')
  final Map<String, String>? languages;
  
  @JsonKey(name: 'area')
  final double? area;
  
  @JsonKey(name: 'timezones')
  final List<String>? timezones;

  const CountryDto({
    required this.id,
    required this.name,
    this.capital,
    required this.population,
    required this.region,
    required this.flags,
    this.currencies,
    this.languages,
    this.area,
    this.timezones,
  });

  factory CountryDto.fromJson(Map<String, dynamic> json) => 
      _$CountryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CountryDtoToJson(this);

  Country toEntity() {
    return Country(
      id: id,
      name: name.common,
      capital: capital?.isNotEmpty == true ? capital!.first : 'N/A',
      population: population,
      region: region,
      flagUrl: flags.png,
      currencies: _formatCurrencies(),
      languages: _formatLanguages(),
      area: area,
      timezones: timezones?.join(', '),
    );
  }

  String? _formatCurrencies() {
    if (currencies == null || currencies!.isEmpty) return null;
    return currencies!.entries
        .map((e) => '${e.value['name']} (${e.value['symbol'] ?? e.key})')
        .join(', ');
  }

  String? _formatLanguages() {
    if (languages == null || languages!.isEmpty) return null;
    return languages!.values.join(', ');
  }
}

@JsonSerializable()
class NameDto {
  final String common;
  final String official;

  const NameDto({required this.common, required this.official});

  factory NameDto.fromJson(Map<String, dynamic> json) => 
      _$NameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NameDtoToJson(this);
}

@JsonSerializable()
class FlagsDto {
  final String png;
  final String svg;

  const FlagsDto({required this.png, required this.svg});

  factory FlagsDto.fromJson(Map<String, dynamic> json) => 
      _$FlagsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FlagsDtoToJson(this);
}
```

#### Implementar Repositorio (`features/countries/data/repositories/countries_repository_impl.dart`)

```dart
import 'package:euro_list/features/countries/data/datasources/restcountries_api.dart';
import 'package:euro_list/features/countries/data/models/country_dto.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';

class CountryRepositoryImpl implements CountryRepository {
  const CountryRepositoryImpl({required this.api});

  final RestCountriesApi api;

  @override
  Future<List<Country>> getEuropeanCountries() async {
    final data = await api.getEuropeanCountries();
    return data.map((json) => CountryDto.fromJson(json).toEntity()).toList();
  }

  @override
  Future<Country> getCountryByName(String name) async {
    final data = await api.getCountryByName(name);
    return CountryDto.fromJson(data).toEntity();
  }
}
```

---

### 4.4 FEATURE WISHLIST - CAPA DATA

#### Crear Base de Datos (`features/wishlist/data/datasources/app_database.dart`)

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart' as domain;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tabla de wishlist
class WishlistItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get flagUrl => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [WishlistItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Obtener todos los items de wishlist
  Future<List<domain.WishlistItem>> getAllWishlistItems() async {
    final items = await select(wishlistItems).get();
    return items.map((item) => domain.WishlistItem(
      id: item.id,
      name: item.name,
      flagUrl: item.flagUrl,
      addedAt: item.addedAt,
    )).toList();
  }

  // Agregar a wishlist
  Future<void> addToWishlist(domain.WishlistItem item) async {
    await into(wishlistItems).insertOnConflictUpdate(
      WishlistItemsCompanion(
        id: Value(item.id),
        name: Value(item.name),
        flagUrl: Value(item.flagUrl),
        addedAt: Value(item.addedAt),
      ),
    );
  }

  // Remover de wishlist
  Future<void> removeFromWishlist(String countryId) async {
    await (delete(wishlistItems)..where((tbl) => tbl.id.equals(countryId))).go();
  }

  // Verificar si está en wishlist
  Future<bool> isInWishlist(String countryId) async {
    final result = await (select(wishlistItems)
      ..where((tbl) => tbl.id.equals(countryId))).getSingleOrNull();
    return result != null;
  }

  // Limpiar wishlist
  Future<void> clearWishlist() async {
    await delete(wishlistItems).go();
  }

  // Contar items
  Future<int> getWishlistCount() async {
    final count = await (select(wishlistItems)).get();
    return count.length;
  }

  // Batch insert (para stress test)
  Future<void> batchInsertWishlistItems(List<domain.WishlistItem> items) async {
    await batch((batch) {
      batch.insertAll(
        wishlistItems,
        items.map((item) => WishlistItemsCompanion(
          id: Value(item.id),
          name: Value(item.name),
          flagUrl: Value(item.flagUrl),
          addedAt: Value(item.addedAt),
        )),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // Batch check status
  Future<Map<String, bool>> batchCheckWishlistStatus(List<String> countryIds) async {
    final items = await (select(wishlistItems)
      ..where((tbl) => tbl.id.isIn(countryIds))).get();
    
    final existingIds = items.map((item) => item.id).toSet();
    return {
      for (final id in countryIds) id: existingIds.contains(id),
    };
  }
}

// Función para abrir la conexión
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wishlist.db'));
    return NativeDatabase(file);
  });
}
```

#### Implementar Repositorio (`features/wishlist/data/repositories/wishlist_repository_impl.dart`)

```dart
import 'dart:async';
import 'package:euro_list/features/wishlist/data/datasources/app_database.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({required AppDatabase database}) 
      : _database = database;

  final AppDatabase _database;
  final StreamController<WishlistChangeEvent> _changeController = 
      StreamController<WishlistChangeEvent>.broadcast();

  @override
  Stream<WishlistChangeEvent> get wishlistChanges => _changeController.stream;

  @override
  Future<List<WishlistItem>> getWishlistItems() async {
    return await _database.getAllWishlistItems();
  }

  @override
  Future<void> addToWishlist(WishlistItem item) async {
    await _database.addToWishlist(item);
    _changeController.add(WishlistChangeEvent(
      type: WishlistChangeType.added,
      countryId: item.id,
    ));
  }

  @override
  Future<void> removeFromWishlist(String countryId) async {
    await _database.removeFromWishlist(countryId);
    _changeController.add(WishlistChangeEvent(
      type: WishlistChangeType.removed,
      countryId: countryId,
    ));
  }

  @override
  Future<bool> isInWishlist(String countryId) async {
    return await _database.isInWishlist(countryId);
  }

  @override
  Future<void> clearWishlist() async {
    await _database.clearWishlist();
    _changeController.add(const WishlistChangeEvent(
      type: WishlistChangeType.cleared,
      countryId: '',
    ));
  }

  @override
  Future<int> getWishlistCount() async {
    return await _database.getWishlistCount();
  }

  @override
  Future<Map<String, bool>> batchCheckWishlistStatus(List<String> countryIds) async {
    return await _database.batchCheckWishlistStatus(countryIds);
  }

  @override
  Future<void> addAllStressTest(List<WishlistItem> items) async {
    // Procesar en chunks para evitar janks
    const chunkSize = 100;
    for (var i = 0; i < items.length; i += chunkSize) {
      final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
      final chunk = items.sublist(i, end);
      await _database.batchInsertWishlistItems(chunk);
      
      // Pequeño delay para no bloquear la UI
      if (i + chunkSize < items.length) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  void dispose() {
    _changeController.close();
  }
}
```

---

### 4.5 Generar Código

**⚠️ PASO CRÍTICO:**

```bash
# Generar archivos .g.dart
flutter packages pub run build_runner build --delete-conflicting-outputs

# O en modo watch (recomendado durante desarrollo)
flutter packages pub run build_runner watch
```

Esto generará:
- `app_database.g.dart`
- `country_dto.g.dart`

---

### 4.6 CAPA PRESENTATION

#### Configurar Inyección de Dependencias (`injection_container.dart`)

```dart
import 'package:euro_list/features/countries/data/datasources/restcountries_api.dart';
import 'package:euro_list/features/countries/data/repositories/countries_repository_impl.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_country_details.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_cubit.dart';
import 'package:euro_list/features/countries/presentation/bloc/country_detail_cubit.dart';
import 'package:euro_list/features/wishlist/data/datasources/app_database.dart';
import 'package:euro_list/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/wishlist/domain/usecases/add_to_wishlist.dart';
import 'package:euro_list/features/wishlist/domain/usecases/batch_check_wishlist_status.dart';
import 'package:euro_list/features/wishlist/domain/usecases/clear_wishlist_stress_test.dart';
import 'package:euro_list/features/wishlist/domain/usecases/get_wishlist_items.dart';
import 'package:euro_list/features/wishlist/domain/usecases/is_in_wishlist.dart';
import 'package:euro_list/features/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'package:euro_list/features/wishlist/presentation/bloc/wishlist_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final api = RestCountriesApi();
  final database = AppDatabase();

  sl
    ..registerLazySingleton<RestCountriesApi>(() => api)
    ..registerLazySingleton<AppDatabase>(() => database)

    // Repositories
    ..registerLazySingleton<CountryRepository>(
      () => CountryRepositoryImpl(api: sl()),
    )
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(database: sl()),
    )

    // Use cases - Countries
    ..registerLazySingleton(() => GetEuropeanCountries(repository: sl()))
    ..registerLazySingleton(() => GetCountryDetails(repository: sl()))
    
    // Use cases - Wishlist
    ..registerLazySingleton(() => GetWishlistItems(repository: sl()))
    ..registerLazySingleton(() => AddToWishlist(repository: sl()))
    ..registerLazySingleton(() => RemoveFromWishlist(repository: sl()))
    ..registerLazySingleton(() => ClearWishlistStressTest(repository: sl()))
    ..registerLazySingleton(() => IsInWishlist(repository: sl()))
    ..registerLazySingleton(() => BatchCheckWishlistStatus(repository: sl()))

    // BLoCs (factories para crear nueva instancia cada vez)
    ..registerFactory(
      () => CountriesCubit(
        getEuropeanCountries: sl(),
        batchCheckWishlistStatus: sl(),
        addToWishlist: sl(),
        removeFromWishlist: sl(),
        wishlistRepository: sl(),
      ),
    )
    ..registerFactory(
      () => CountryDetailCubit(
        getCountryDetails: sl(),
        isInWishlist: sl(),
        addToWishlist: sl(),
        removeFromWishlist: sl(),
        wishlistRepository: sl(),
      ),
    )
    ..registerFactory(
      () => WishlistCubit(
        getWishlistItems: sl(),
        removeFromWishlist: sl(),
        clearWishlist: sl(),
        wishlistRepository: sl(),
      ),
    );
}
```

#### Crear Estados y Cubits

Ver los archivos que ya tienes en:
- `features/countries/presentation/bloc/`
- `features/wishlist/presentation/bloc/`

#### Configurar `main.dart`

```dart
import 'package:euro_list/injection_container.dart' as di;
import 'package:euro_list/features/countries/presentation/pages/countries_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar inyección de dependencias
  await di.init();
  
  runApp(const EuroListApp());
}

class EuroListApp extends StatelessWidget {
  const EuroListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EuroList',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CountriesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## ⚙️ Paso 5: Ejecutar el Proyecto

```bash
# Asegurarse de que todo está generado
flutter packages pub run build_runner build --delete-conflicting-outputs

# Limpiar si hay problemas
flutter clean
flutter pub get

# Ejecutar
flutter run
```

---

## 🧪 Paso 6: Crear Tests

**Estructura de tests (misma organización):**

```
test/
├── features/
│   ├── countries/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       └── get_european_countries_test.dart
│   │   └── data/
│   │       └── repositories/
│   │           └── countries_repository_impl_test.dart
│   └── wishlist/
│       ├── domain/
│       └── data/
└── core/
```

**Ejemplo de test:**

```dart
// test/features/countries/domain/usecases/get_european_countries_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';

class MockCountryRepository extends Mock implements CountryRepository {}

void main() {
  late GetEuropeanCountries usecase;
  late MockCountryRepository mockRepository;

  setUp(() {
    mockRepository = MockCountryRepository();
    usecase = GetEuropeanCountries(repository: mockRepository);
  });

  test('should get list of countries from repository', () async {
    // Arrange
    final tCountries = [
      const Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flags.com/spain.png',
      ),
    ];
    when(() => mockRepository.getEuropeanCountries())
        .thenAnswer((_) async => tCountries);

    // Act
    final result = await usecase();

    // Assert
    expect(result, tCountries);
    verify(() => mockRepository.getEuropeanCountries());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

**Ejecutar tests:**
```bash
flutter test
```

---

## 🚨 ADVERTENCIA: LA TRAMPA DEL PDF

### ⚠️ **ENDPOINT INCORRECTO EN EL PDF (LÍNEA 9)**

El PDF te indica usar este endpoint para obtener detalles del país:
```
❌ https://restcountries.com/v3.1/translation/{nombre}
```

**¡ESTO ES UNA TRAMPA!** Este endpoint:
- ✗ NO está diseñado para obtener UN país específico
- ✗ Busca países cuyas traducciones contengan ese texto
- ✗ Puede devolver múltiples resultados o ninguno
- ✗ No es confiable para obtener detalles

### ✅ **EL ENDPOINT CORRECTO ES:**

```
✓ https://restcountries.com/v3.1/name/{name}
```

---

## 📝 Checklist Final

Antes de entregar, verifica:

- [ ] **Arquitectura Feature-First**
  - [ ] Features separadas (countries, wishlist)
  - [ ] Cada feature con su domain/data/presentation
  - [ ] Core para código compartido
  - [ ] Dependency injection con GetIt configurado

- [ ] **Requisitos Técnicos**
  - [ ] Dio con cache interceptor funcionando
  - [ ] BLoC pattern para gestión de estado
  - [ ] Drift para base de datos local
  - [ ] ⚠️ **CRÍTICO: Usar `/name/{name}` NO `/translation/{nombre}`**
  - [ ] Cache configurado correctamente
  - [ ] Prevención de janks (chunks, delays)

- [ ] **Funcionalidad**
  - [ ] Lista de países europeos
  - [ ] Detalles de país con caché (endpoint correcto)
  - [ ] Agregar/eliminar de wishlist
  - [ ] Página de wishlist
  - [ ] Persistencia entre sesiones

- [ ] **Testing**
  - [ ] Tests unitarios para use cases
  - [ ] Tests para repositorios
  - [ ] Tests para BLoCs
  - [ ] Casos de éxito y error cubiertos

- [ ] **Código**
  - [ ] Análisis estático sin errores (`flutter analyze`)
  - [ ] Código formateado (`dart format .`)
  - [ ] Buenas prácticas y Clean Code
  - [ ] Imports organizados por feature

---

## 🚀 Comandos Rápidos de Referencia

```bash
# Setup inicial
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs

# Desarrollo
flutter run
flutter packages pub run build_runner watch  # Auto-generar código

# Testing
flutter test
flutter test --coverage

# Calidad
flutter analyze
dart format .
dart fix --apply

# Limpieza
flutter clean
```

---

## 🎯 Ventajas de Feature-First vs Layer-First

### Layer-First (Antiguo):
```
lib/domain/entities/country.dart
lib/domain/entities/wishlist_item.dart
lib/data/models/country_dto.dart
lib/data/models/wishlist_item_dto.dart
```
❌ Todo mezclado por capas

### Feature-First (Nuevo):
```
lib/features/countries/domain/entities/country.dart
lib/features/countries/data/models/country_dto.dart
lib/features/wishlist/domain/entities/wishlist_item.dart
lib/features/wishlist/data/models/wishlist_item_dto.dart
```
✅ Organizado por funcionalidad

### Beneficios:
- ✅ **Escalabilidad**: Agregar features es más fácil
- ✅ **Mantenibilidad**: Todo de una feature está junto
- ✅ **Colaboración**: Diferentes devs en diferentes features
- ✅ **Modularización**: Cada feature puede ser un paquete
- ✅ **Navegación**: Más fácil encontrar código relacionado

---

## 📚 Recursos Adicionales

- **API REST Countries**: https://restcountries.com/
- **Flutter BLoC**: https://bloclibrary.dev/
- **Drift Documentation**: https://drift.simonbinder.eu/
- **Clean Architecture**: Uncle Bob's principles
- **Feature-First Architecture**: DDD approach

---

**¡Éxito en tu prueba técnica! 🚀**

**Recuerda: Usa la arquitectura Feature-First y el endpoint correcto `/name/{name}`**
