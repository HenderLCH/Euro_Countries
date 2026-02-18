# EuroList (Euro Explorer)

Aplicación Flutter que lista países europeos obtenidos por API, permite agregarlos a una lista de deseos (wishlist) persistente y consultar el detalle de cada país. Desarrollada con **Clean Architecture**, **BLoC** y **persistencia local con Drift**.

---

## Descripción del proyecto

EuroList es una app multiplataforma que:

- **Lista países europeos** obtenidos desde la API [REST Countries](https://restcountries.com/).
- Permite **agregar o quitar países de una wishlist** (lista de deseos).
- Muestra el **detalle de cada país** (capital, región, población, bandera, etc.).
- **Persiste la wishlist** en dispositivo con SQLite (Drift).
- Incluye un **Stress Test** que agrega todos los países europeos a la wishlist para demostrar manejo de performance (anti-janks).

La arquitectura sigue **Clean Architecture** y organización **Feature-First**, con inyección de dependencias (GetIt), BLoC para el estado y pruebas unitarias en Domain, Data y Presentation.

---

## Qué hay que hacer en el programa (flujo de la app)

1. **Al abrir la app**  
   Se cargan los países europeos desde la API (con caché). Se muestra un grid de tarjetas (bandera, nombre, capital).

2. **En cada tarjeta**  
   - Botón **"Add to Wishlist"** / **"Added"** para agregar o quitar el país de la lista de deseos.  
   - Tap en la tarjeta abre la **página de detalle** del país.

3. **Página de detalle**  
   Muestra capital, región, población, bandera y opción de agregar a la wishlist.

4. **Wishlist**  
   Acceso desde el AppBar (**"View Wishlist"**). Lista de países guardados; se pueden eliminar uno a uno o usar el menú para **"Stress Test"** o **"Clear All"**.

5. **Stress Test**  
   Desde el menú de la wishlist, **"Stress Test"** obtiene todos los países europeos de la API y los agrega a la wishlist en lotes (chunking) para evitar janks. Al finalizar se muestra un mensaje con la cantidad de ítems y el tiempo empleado.

6. **Sincronización**  
   Si se elimina un país desde la wishlist, el botón en la lista principal se actualiza automáticamente (gracias al stream de cambios del repositorio).

---

## Stack técnico

- **Flutter** (Dart)
- **Estado:** flutter_bloc (Cubit)
- **HTTP y caché:** Dio, dio_cache_interceptor, dio_cache_interceptor_db_store
- **Persistencia:** Drift (SQLite)
- **Inyección de dependencias:** GetIt
- **Imágenes:** cached_network_image
- **Tests:** flutter_test, mocktail, bloc_test

---

## Arquitectura

El proyecto usa **Clean Architecture** con organización **Feature-First**:

```
lib/
├── main.dart                 # Entrada; llama a di.init() y runApp()
├── injection_container.dart  # Registro de todas las dependencias (GetIt)
├── core/                     # Widgets y tema compartidos
└── features/
    ├── countries/            # Feature: países europeos
    │   ├── domain/           # Entidades, contratos (repositories), use cases
    │   ├── data/             # API, DTOs, implementación de repositories
    │   └── presentation/     # BLoC, páginas, widgets
    └── wishlist/             # Feature: lista de deseos
        ├── domain/
        ├── data/             # Drift (AppDatabase), repository impl
        └── presentation/
```

- **Domain:** no depende de Flutter, Dio ni Drift. Solo entidades y contratos.
- **Data:** implementa los contratos (repositories), usa API y base de datos.
- **Presentation:** UI y estado (Cubits); usa solo Domain.

Toda la **inicialización y conexión de dependencias** se hace en `injection_container.dart`; el arranque en `main.dart` con `await di.init()`.

---

## Estructura del proyecto

| Ruta | Contenido |
|------|-----------|
| `lib/main.dart` | Punto de entrada; inicializa DI y arranca la app. |
| `lib/injection_container.dart` | Registro GetIt: API, DB, repositories, use cases, Cubits. |
| `lib/core/` | Tema, widgets reutilizables (loading, error, banderas). |
| `lib/features/countries/` | Listado de países, detalle, integración con API. |
| `lib/features/wishlist/` | Wishlist, Drift, stress test, sincronización. |
| `test/` | Pruebas unitarias (domain, data, presentation). |

---

## Cómo ejecutar

### Requisitos

- Flutter SDK estable.  
  [Instalación](https://docs.flutter.dev/get-started/install)

### Pasos

1. Clonar o abrir el proyecto y instalar dependencias:

```bash
flutter pub get
```

2. Ejecutar la app:

```bash
# En Windows (recomendado para desarrollo)
flutter run -d windows

# En Android (emulador o dispositivo con depuración USB)
flutter run -d android

# Listar dispositivos disponibles
flutter devices
```

**Nota:** La app **no** se ejecuta en **web** porque Drift usa `dart:ffi`, no disponible en navegador.

3. Generar APK (Android):

```bash
flutter build apk --release
```

---

## Pruebas

Se incluyen pruebas unitarias para Domain (entidades, use cases), Data (repositories, base de datos) y Presentation (Cubits).

Ejecutar todos los tests:

```bash
flutter test
```

Los tests verifican, entre otras cosas:

- Uso correcto de repositories y use cases.
- Conversión DTO ↔ entidad.
- Operaciones CRUD y batch de la wishlist.
- Emisión de estados de los Cubits (BLoC).
- Lógica de chunking en el stress test.

---

## Documentación adicional

En el repositorio hay documentación de apoyo:

- **ARQUITECTURA_PARA_ENTREVISTA.md** — Clean Architecture, dónde se declara todo, flujo de la app y preguntas frecuentes.
- **DOCUMENTACION_TECNICA.md** — Detalle técnico por capas, flujos y tests.
- **PRESENTACION_SENIORS.md** — Guía para presentar el proyecto.
- **CHEAT_SHEET.md** — Referencia rápida y comandos.
- **EXPLICACION_TESTS.md** — Explicación de los tests (AAA, mocks, bloc_test).
- **CODIGO_COMENTARIOS.md** — Plantilla para comentarios clave del código.

---

## Licencia

Indicar la licencia del proyecto (p. ej. MIT) o eliminar esta sección si no aplica.

---

## Contacto

Para dudas o colaboración, abrir un issue en el repositorio o contactar al responsable del proyecto.
