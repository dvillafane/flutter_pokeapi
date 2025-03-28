// se importan los paquetes necesarios
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokeapi/screens/login_screen.dart';
import 'package:flutter_pokeapi/models/pokemon.dart';
import 'package:flutter_pokeapi/models/poke_api_service.dart';

// se define un widget con estado para la pantalla principal
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// estado asociado al widget MyHomePage
class _MyHomePageState extends State<MyHomePage> {
  final PokeApiService _apiService = PokeApiService();
  late Future<Pokemon> _pokemonFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pokemonFuture = _apiService.fetchPokemon('pikachu');
  }

  // funcióon que actualiza la búsqueda de un Pokemon segun el texto ingresado
  void _searchPokemon(String query) {
    setState(() {
      _pokemonFuture = _apiService.fetchPokemon(query.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // define el color de fondo de la pantalla
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        // configura el color del AppBar
        backgroundColor: Colors.blue[800],
        // titulo de la AppBar
        title: const Text("Pokedex", style: TextStyle(color: Colors.white)),
        actions: [
          // boton para mostrar el cuadro de búsqueda
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => showSearchDialog(context),
          ),
          // boton para cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // se cierra la sesión con Firebase
              FirebaseAuth.instance.signOut();
              // se navega a la pantalla de login y se elimina la ruta actual
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      // el cuerpo de la pantalla usa FutureBuilder para manejar el estado de la petición
      body: FutureBuilder<Pokemon>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          // mientras se espera la respuesta se muestra un indicador de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
            // si ocurre un error se muestra un mensaje de error
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
            // si se recibe el dato se muestra el widget con los detalles del Pokemon
          } else if (snapshot.hasData) {
            return PokemonDetails(pokemon: snapshot.data!);
          }
          // mensaje predeterminado en caso de no tener datos
          return const Center(child: Text('Busca un Pokémon'));
        },
      ),
    );
  }

  // función para mostrar un dialogo de búsqueda
  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            // título del dialogo
            title: const Text('Buscar Pokémon'),
            // contenido del dialogo campo de texto para ingresar el nombre o ID
            content: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Nombre o ID',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              // botón para cancelar la búsqueda y cerrar el diálogo
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              // boton para iniciar la búsqueda
              ElevatedButton(
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    // Se llama a la función que realiza la busqueda
                    _searchPokemon(_searchController.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                ),
                child: const Text('Buscar'),
              ),
            ],
          ),
    );
  }
}

// widget que muestra los detalles de un Pokemon
class PokemonDetails extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetails({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // muestra la imagen del Pokemon desde una URL
                Image.network(
                  pokemon.imageUrl,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    // mientras se carga la imagen se muestra un indicador
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  // muestra el nombre del Pokemon con la primera letra en mayuscula
                  pokemon.name.capitalize(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // muestra el ID del Pokemon con formato
                Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                // muestra los tipos del Pokemon en forma de chips
                Wrap(
                  spacing: 10,
                  children:
                      pokemon.types
                          .map(
                            (type) => Chip(
                              label: Text(
                                type.capitalize(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              // se asigna un color según el tipo del Pokemon
                              backgroundColor: _getTypeColor(type),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // función auxiliar que asigna un color a cada tipo de Pokemon
  Color _getTypeColor(String type) {
    final typeColors = {
      'fire': Colors.orange,
      'water': Colors.blue,
      'grass': Colors.green,
      'electric': Colors.yellow,
      'psychic': Colors.purple,
      'ice': Colors.cyan,
      'dragon': Colors.indigo,
      'dark': Colors.brown,
      'fairy': Colors.pink,
      'normal': Colors.grey,
      'fighting': Colors.orange[800]!,
      'flying': Colors.blue[200]!,
      'poison': Colors.purple[800]!,
      'ground': Colors.brown[400]!,
      'rock': Colors.brown[600]!,
      'bug': Colors.green[600]!,
      'ghost': Colors.purple[900]!,
      'steel': Colors.blueGrey,
    };
    // si no se encuentra el tipo se asigna gris por defecto
    return typeColors[type] ?? Colors.grey;
  }
}

// extension para añadir el método "capitalize" a la clase String
extension StringExtension on String {
  // metodo que capitaliza la primera letra y pone en minusculas el resto
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
