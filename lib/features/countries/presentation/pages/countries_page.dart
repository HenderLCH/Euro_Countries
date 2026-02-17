import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:euro_list/injection_container.dart' as di;
import 'package:euro_list/features/countries/presentation/bloc/countries_cubit.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_state.dart';
import 'package:euro_list/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:euro_list/features/countries/presentation/pages/country_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CountriesPage extends StatefulWidget {
  const CountriesPage({super.key});

  @override
  State<CountriesPage> createState() => _CountriesPageState();
}

class _CountriesPageState extends State<CountriesPage> {
  bool _imagesPrecached = false;

  void _precacheImages(BuildContext context, List<String> flagUrls) {
    if (_imagesPrecached) return;
    _imagesPrecached = true;

    // Precachear las primeras 20 imágenes para scroll fluido
    for (int i = 0; i < flagUrls.length && i < 20; i++) {
      final url = flagUrls[i];
      if (!url.toLowerCase().endsWith('.svg')) {
        precacheImage(
          CachedNetworkImageProvider(url),
          context,
          onError: (exception, stackTrace) {
            debugPrint('Error precaching flag $url: $exception');
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CountriesCubit>()..loadCountries(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('European Countries'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WishlistPage(),
                  ),
                );
              },
              child: const Text(
                'View Wishlist',
                style: TextStyle(color: Colors.black,
                fontWeight: FontWeight.bold,),
              )
            ),
          ],
        ),
        body: BlocBuilder<CountriesCubit, CountriesState>(
          builder: (context, state) {
            if (state is CountriesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is CountriesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            
            if (state is CountriesLoaded) {
              // Precachear imágenes para mejor rendimiento
              _precacheImages(
                context,
                state.countries.map((c) => c.flagUrl).toList(),
              );
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                cacheExtent: 1000, // Pre-renderiza más items fuera de pantalla
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 4 columnas
                  childAspectRatio: 0.75, // Proporción ancho/alto
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.countries.length,
                itemBuilder: (context, index) {
                  final country = state.countries[index];
                  final isInWishlist = state.wishlistStatus[country.id] ?? false;
                  
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CountryDetailPage(
                              countryName: country.name,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Bandera con caché optimizado
                          Expanded(
                            flex: 3,
                            child: CachedNetworkImage(
                              imageUrl: country.flagUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.flag, size: 50, color: Colors.grey),
                                ),
                              ),
                              memCacheWidth: 400, // Limita el ancho en memoria
                              maxWidthDiskCache: 400, // Limita el ancho en disco
                            ),
                          ),
                          // Información
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    country.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    country.capital ?? 'No capital',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  // Botón Add to Wishlist
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<CountriesCubit>().toggleWishlist(
                                          country.id,
                                          country.name,
                                          country.flagUrl,
                                        );
                                      },
                                      icon: Icon(
                                        isInWishlist ? Icons.check : Icons.add,
                                        size: 16,
                                      ),
                                      label: Text(
                                        isInWishlist ? 'Added' : 'Add to Wishlist',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        backgroundColor: isInWishlist 
                                          ? Colors.green 
                                          : Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            
            return const SizedBox();
          },
        ),
      ),
    );
  }
}