import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:euro_list/injection_container.dart' as di;
import 'package:euro_list/features/countries/presentation/bloc/countries_cubit.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_state.dart';
import 'package:euro_list/features/countries/presentation/widgets/country_card.dart';
import 'package:euro_list/features/wishlist/presentation/pages/wishlist_page.dart';
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

    //Precachear las primeras 20 imagenes para hacer un scroll fluidio
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
  
//Pagina pincipal

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
              _precacheImages(
                context,
                state.countries.map((c) => c.flagUrl).toList(),
              );
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                cacheExtent: 1000,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.countries.length,
                itemBuilder: (context, index) {
                  final country = state.countries[index];
                  final isInWishlist = state.wishlistStatus[country.id] ?? false;
                  
                  return CountryCard(
                    country: country,
                    isInWishlist: isInWishlist,
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