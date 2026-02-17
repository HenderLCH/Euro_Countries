# Diagrama Visual de la Estructura

## Arquitectura Completa

```
┌─────────────────────────────────────────────────────────────────┐
│                         APLICACIÓN                               │
│                      (main.dart + DI)                            │
└──────────────────────┬──────────────────────────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
┌────────▼─────────┐        ┌────────▼─────────┐
│  FEATURE:        │        │  FEATURE:        │
│  COUNTRIES 🌍    │        │  WISHLIST ⭐     │
└──────────────────┘        └──────────────────┘
```

## Feature: Countries 🌍

```
countries/
│
├── presentation/           ← CAPA DE PRESENTACIÓN (UI)
│   ├── bloc/
│   │   ├── countries_cubit.dart       (Lista de países)
│   │   ├── countries_state.dart
│   │   ├── country_detail_cubit.dart  (Detalle de país)
│   │   └── country_detail_state.dart
│   │
│   ├── pages/
│   │   ├── countries_page.dart        (Pantalla principal)
│   │   └── country_detail_page.dart   (Pantalla de detalle)
│   │
│   └── widgets/
│       ├── country_cart.dart          (Tarjeta de país)
│       └── smart_flag_image.dart      (Imagen de bandera optimizada)
│
├── domain/                ← CAPA DE DOMINIO (Lógica de Negocio)
│   ├── entities/
│   │   └── country.dart               (Entidad Country)
│   │
│   ├── repositories/
│   │   └── country_repository.dart    (Interface del repositorio)
│   │
│   └── usecases/
│       ├── get_european_countries.dart (Obtener lista de países)
│       └── get_country_details.dart    (Obtener detalles de un país)
│
└── data/                  ← CAPA DE DATOS (Implementación)
    ├── models/
    │   └── country_dto.dart           (DTO para serialización)
    │
    ├── datasources/
    │   └── restcountries_api.dart     (API REST Countries)
    │
    └── repositories/
        └── countries_repository_impl.dart (Implementación del repositorio)
```

## Feature: Wishlist ⭐

```
wishlist/
│
├── presentation/           ← CAPA DE PRESENTACIÓN (UI)
│   ├── bloc/
│   │   ├── wishlist_cubit.dart        (Gestión de estado)
│   │   └── wishlist_state.dart
│   │
│   └── pages/
│       └── wishlist_page.dart         (Pantalla de favoritos)
│
├── domain/                ← CAPA DE DOMINIO (Lógica de Negocio)
│   ├── entities/
│   │   └── wishlist_item.dart         (Entidad WishlistItem)
│   │
│   ├── repositories/
│   │   └── wishlist_repository.dart   (Interface del repositorio)
│   │
│   └── usecases/
│       └── manage_wishlist.dart       (Casos de uso de wishlist)
│           ├── GetWishlistItems
│           ├── AddToWishlist
│           ├── RemoveFromWishlist
│           ├── IsInWishlist
│           ├── BatchCheckWishlistStatus
│           └── ClearWishlistStressTest
│
└── data/                  ← CAPA DE DATOS (Implementación)
    ├── models/
    │   └── whislist_item_dto.dart     (DTO para serialización)
    │
    ├── datasources/
    │   ├── app_database.dart          (Base de datos local - Drift)
    │   └── data_procesing_isolates.dart (Procesamiento en isolates)
    │
    └── repositories/
        └── wishlist_repository_impl.dart (Implementación del repositorio)
```

## Core (Compartido) 🔧

```
core/
│
├── theme/
│   └── app_theme.dart                 (Tema de la aplicación)
│
├── utils/
│   ├── flag_perfomance_optimizer.dart (Optimización de banderas)
│   └── performance_monitor.dart       (Monitor de rendimiento)
│
└── widgets/                           (Widgets compartidos)
    ├── error_widget.dart              (Widget de error)
    └── loading_widget.dart            (Widget de carga)
```

## Flujo de Dependencias

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION                           │
│  (Blocs, Cubits, Pages, Widgets)                           │
│                                                             │
│  • Muestra UI                                               │
│  • Maneja eventos del usuario                              │
│  • Usa casos de uso del dominio                            │
└───────────────────────┬─────────────────────────────────────┘
                        │ depende de ↓
┌───────────────────────▼─────────────────────────────────────┐
│                        DOMAIN                               │
│  (Entities, UseCases, Repository Interfaces)               │
│                                                             │
│  • Lógica de negocio pura                                  │
│  • Sin dependencias de Flutter                             │
│  • Define contratos (interfaces)                           │
└───────────────────────┬─────────────────────────────────────┘
                        │ ← implementado por
┌───────────────────────▼─────────────────────────────────────┐
│                         DATA                                │
│  (Models/DTOs, DataSources, Repository Implementations)    │
│                                                             │
│  • Implementa repositorios                                 │
│  • Maneja APIs y bases de datos                            │
│  • Transforma DTOs a Entities                              │
└─────────────────────────────────────────────────────────────┘
```

## Regla de Oro

```
❌ NUNCA:
   data → presentation
   domain → data
   domain → presentation
   feature_a → feature_b (directamente)

✅ SIEMPRE:
   presentation → domain
   data → domain
   cualquier capa → core
```

## Ejemplo de Flujo Completo

```
Usuario toca "Ver países" en la UI
         │
         ▼
┌────────────────────────┐
│ countries_page.dart    │ ← PRESENTATION
│ (UI)                   │
└────────┬───────────────┘
         │ evento
         ▼
┌────────────────────────┐
│ countries_cubit.dart   │ ← PRESENTATION (State Management)
│ (BLoC)                 │
└────────┬───────────────┘
         │ llama
         ▼
┌────────────────────────┐
│ get_european_countries │ ← DOMAIN (UseCase)
│ (Caso de Uso)          │
└────────┬───────────────┘
         │ usa
         ▼
┌────────────────────────┐
│ country_repository     │ ← DOMAIN (Interface)
│ (Contrato)             │
└────────┬───────────────┘
         │ implementado por
         ▼
┌────────────────────────┐
│ countries_repository   │ ← DATA (Implementation)
│ _impl.dart             │
└────────┬───────────────┘
         │ usa
         ▼
┌────────────────────────┐
│ restcountries_api.dart │ ← DATA (DataSource)
│ (API)                  │
└────────┬───────────────┘
         │ retorna datos
         ▼
    Transforma DTO → Entity
         │
         ▼
    Retorna al Cubit
         │
         ▼
    Actualiza UI
```

## Ventajas de Esta Estructura

1. **Aislamiento**: Cada feature es independiente
2. **Testeable**: Fácil hacer unit tests en cada capa
3. **Escalable**: Agregar features no afecta las existentes
4. **Mantenible**: Es fácil encontrar y modificar código
5. **Colaborativo**: Diferentes devs pueden trabajar en diferentes features

## Próximos Features Potenciales

Si quisieras agregar nuevas funcionalidades, la estructura sería:

```
lib/features/
├── countries/     (✅ existente)
├── wishlist/      (✅ existente)
├── auth/          (🆕 nuevo feature)
├── favorites/     (🆕 nuevo feature)
└── settings/      (🆕 nuevo feature)
```

Cada uno con su propia estructura domain/data/presentation.
