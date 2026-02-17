# Script para actualizar los imports a la nueva estructura Feature-First
# Ejecutar desde la raíz del proyecto

Write-Host "Actualizando imports a la nueva estructura..." -ForegroundColor Green

$libPath = ".\lib"
$dartFiles = Get-ChildItem -Path $libPath -Recurse -Filter *.dart

# Mapeo de rutas antiguas a nuevas
$importMappings = @{
    # Countries - Domain
    "package:euro_list/domain/entities/country.dart" = "package:euro_list/features/countries/domain/entities/country.dart"
    "package:euro_list/domain/repositories/country_repository.dart" = "package:euro_list/features/countries/domain/repositories/country_repository.dart"
    "package:euro_list/domain/usecases/get_european_countries.dart" = "package:euro_list/features/countries/domain/usecases/get_european_countries.dart"
    "package:euro_list/domain/usecases/get_country_details.dart" = "package:euro_list/features/countries/domain/usecases/get_country_details.dart"
    
    # Wishlist - Domain
    "package:euro_list/domain/entities/wishlist_item.dart" = "package:euro_list/features/wishlist/domain/entities/wishlist_item.dart"
    "package:euro_list/domain/repositories/wishlist_repository.dart" = "package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart"
    "package:euro_list/domain/usecases/manage_wishlist.dart" = "package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart"
    
    # Countries - Data
    "package:euro_list/data/models/country_dto.dart" = "package:euro_list/features/countries/data/models/country_dto.dart"
    "package:euro_list/data/repositories/countries_repository_impl.dart" = "package:euro_list/features/countries/data/repositories/countries_repository_impl.dart"
    "package:euro_list/data/datasources/remote/restcountries_api.dart" = "package:euro_list/features/countries/data/datasources/restcountries_api.dart"
    
    # Wishlist - Data
    "package:euro_list/data/models/whislist_item_dto.dart" = "package:euro_list/features/wishlist/data/models/whislist_item_dto.dart"
    "package:euro_list/data/repositories/wishlist_repository_impl.dart" = "package:euro_list/features/wishlist/data/repositories/wishlist_repository_impl.dart"
    "package:euro_list/data/datasources/local/app_database.dart" = "package:euro_list/features/wishlist/data/datasources/app_database.dart"
    "package:euro_list/data/isolates/data_procesing_isolates.dart" = "package:euro_list/features/wishlist/data/datasources/data_procesing_isolates.dart"
    
    # Countries - Presentation
    "package:euro_list/presentation/blocs/countries/countries_cubit.dart" = "package:euro_list/features/countries/presentation/bloc/countries_cubit.dart"
    "package:euro_list/presentation/blocs/countries/countries_state.dart" = "package:euro_list/features/countries/presentation/bloc/countries_state.dart"
    "package:euro_list/presentation/blocs/country_detail/country_detail_cubit.dart" = "package:euro_list/features/countries/presentation/bloc/country_detail_cubit.dart"
    "package:euro_list/presentation/blocs/country_detail/country_detail_state.dart" = "package:euro_list/features/countries/presentation/bloc/country_detail_state.dart"
    "package:euro_list/presentation/pages/countries_page.dart" = "package:euro_list/features/countries/presentation/pages/countries_page.dart"
    "package:euro_list/presentation/pages/country_detail_page.dart" = "package:euro_list/features/countries/presentation/pages/country_detail_page.dart"
    "package:euro_list/presentation/widgets/country_cart.dart" = "package:euro_list/features/countries/presentation/widgets/country_cart.dart"
    "package:euro_list/presentation/widgets/smart_flag_image.dart" = "package:euro_list/features/countries/presentation/widgets/smart_flag_image.dart"
    
    # Wishlist - Presentation
    "package:euro_list/presentation/blocs/wishlist/wishlist_cubit.dart" = "package:euro_list/features/wishlist/presentation/bloc/wishlist_cubit.dart"
    "package:euro_list/presentation/blocs/wishlist/wishlist_state.dart" = "package:euro_list/features/wishlist/presentation/bloc/wishlist_state.dart"
    "package:euro_list/presentation/pages/wishlist_page.dart" = "package:euro_list/features/wishlist/presentation/pages/wishlist_page.dart"
    
    # Core
    "package:euro_list/presentation/theme/app_theme.dart" = "package:euro_list/core/theme/app_theme.dart"
    "package:euro_list/presentation/widgets/error_widget.dart" = "package:euro_list/core/widgets/error_widget.dart"
    "package:euro_list/presentation/widgets/loading_widget.dart" = "package:euro_list/core/widgets/loading_widget.dart"
    "package:euro_list/utils/flag_perfomance_optimizer.dart" = "package:euro_list/core/utils/flag_perfomance_optimizer.dart"
    "package:euro_list/utils/performance_monitor.dart" = "package:euro_list/core/utils/performance_monitor.dart"
}

$filesUpdated = 0
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    foreach ($oldImport in $importMappings.Keys) {
        $newImport = $importMappings[$oldImport]
        $content = $content -replace [regex]::Escape($oldImport), $newImport
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $filesUpdated++
        Write-Host "  ✓ Actualizado: $($file.Name)" -ForegroundColor Cyan
    }
}

Write-Host "`nResumen:" -ForegroundColor Green
Write-Host "  Archivos actualizados: $filesUpdated" -ForegroundColor Yellow
Write-Host "`n¡Imports actualizados correctamente!" -ForegroundColor Green
Write-Host "Ejecuta 'flutter pub get' y verifica que no haya errores." -ForegroundColor Yellow
