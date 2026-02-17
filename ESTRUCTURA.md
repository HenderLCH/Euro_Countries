# Estructura del Proyecto - Feature-First Clean Architecture

Este proyecto ha sido reorganizado siguiendo una arquitectura limpia (Clean Architecture) orientada a features, en lugar de la estructura tradicional por capas.

## Estructura de Carpetas

```
lib/
├── features/
│   ├── countries/              # Feature: Gestión de países
│   │   ├── domain/
│   │   │   ├── entities/       # country.dart
│   │   │   ├── repositories/   # country_repository.dart (interfaz)
│   │   │   └── usecases/       # get_european_countries, get_country_details
│   │   ├── data/
│   │   │   ├── models/         # country_dto.dart
│   │   │   ├── datasources/    # restcountries_api.dart
│   │   │   └── repositories/   # countries_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/           # countries_cubit, country_detail_cubit
│   │       ├── pages/          # countries_page, country_detail_page
│   │       └── widgets/        # country_cart, smart_flag_image
│   │
│   └── wishlist/               # Feature: Gestión de lista de deseos
│       ├── domain/
│       │   ├── entities/       # wishlist_item.dart
│       │   ├── repositories/   # wishlist_repository.dart (interfaz)
│       │   └── usecases/       # manage_wishlist.dart
│       ├── data/
│       │   ├── models/         # whislist_item_dto.dart
│       │   ├── datasources/    # app_database.dart, data_procesing_isolates.dart
│       │   └── repositories/   # wishlist_repository_impl.dart
│       └── presentation/
│           ├── bloc/           # wishlist_cubit, wishlist_state
│           ├── pages/          # wishlist_page
│           └── widgets/
│
├── core/                       # Código compartido entre features
│   ├── theme/                  # app_theme.dart
│   ├── utils/                  # flag_perfomance_optimizer, performance_monitor
│   └── widgets/                # error_widget, loading_widget (compartidos)
│
├── injection_container.dart    # Configuración de inyección de dependencias
└── main.dart                   # Punto de entrada de la aplicación
```

## Ventajas de Feature-First vs Layer-First

### Estructura Anterior (Layer-First):
```
lib/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
└── presentation/
    ├── blocs/
    ├── pages/
    └── widgets/
```

### Estructura Actual (Feature-First):
- **Mejor escalabilidad**: Cada feature es independiente
- **Mantenimiento más fácil**: Todo relacionado a una feature está en un solo lugar
- **Trabajo en equipo**: Diferentes developers pueden trabajar en features distintas sin conflictos
- **Modularización**: Cada feature puede convertirse en un paquete independiente si es necesario
- **Navegación más intuitiva**: Es más fácil encontrar código relacionado

## Principios de Clean Architecture Mantenidos

1. **Capa de Dominio (Domain)**: Lógica de negocio pura, sin dependencias externas
   - Entities: Modelos de negocio
   - Repositories: Interfaces (contratos)
   - UseCases: Casos de uso de la aplicación

2. **Capa de Datos (Data)**: Implementación de repositorios y fuentes de datos
   - Models (DTOs): Modelos para serialización
   - DataSources: API, Base de datos local
   - Repositories: Implementación concreta de interfaces

3. **Capa de Presentación (Presentation)**: UI y gestión de estado
   - BLoC/Cubit: Gestión de estado
   - Pages: Pantallas principales
   - Widgets: Componentes reutilizables

4. **Core**: Código compartido entre todas las features
   - Theme, Utils, Widgets compartidos

## Regla de Dependencias

```
Presentation → Domain ← Data
      ↓          ↓        ↓
         Core (compartido)
```

- Presentation depende de Domain
- Data depende de Domain
- Domain NO depende de nadie (excepto Core si es necesario)
- Las features NO deben depender entre sí directamente

## Imports Actualizados

Todos los imports han sido actualizados para reflejar la nueva estructura:

```dart
// Antes
import 'package:euro_list/domain/entities/country.dart';

// Ahora
import 'package:euro_list/features/countries/domain/entities/country.dart';
```
