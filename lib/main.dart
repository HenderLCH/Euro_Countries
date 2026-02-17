import 'package:euro_list/injection_container.dart' as di;
import 'package:euro_list/features/countries/presentation/pages/countries_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializo las dependencias
  await di.init();
  
  runApp(const EuroExplorerApp());
}

class EuroExplorerApp extends StatelessWidget {
  const EuroExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EuroExplorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CountriesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}