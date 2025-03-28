// se importan los paquetes necesarios
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon.dart';

// clase que encapsula los metodos para interactuar con la API de Pokemon
class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  // metodo asincrono que obtiene la informacion de un Pokemon dado un identificador (nombre o ID)
  Future<Pokemon> fetchPokemon(String identifier) async {
    // realiza una petición GET a la URL construida con el identificador
    final response = await http.get(Uri.parse('$_baseUrl/pokemon/$identifier'));

    // Si la respuesta es exitosa se parsea el JSON y se crea un objeto Pokemon
    if (response.statusCode == 200) {
      return Pokemon.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Pokémon no encontrado');
    } else {
      throw Exception('Error en la API: ${response.statusCode}');
    }
  }
}
