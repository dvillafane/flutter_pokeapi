// Se define la clase 'Pokemon' que representa el modelo de datos de un Pokemon
class Pokemon {
  // propiedades del Pokemon
  final int id;
  final String name;
  final List<String> types;
  final String imageUrl;

  // constructor de la clase donde se inicializan todas las propiedades
  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.imageUrl,
  });

  // constructor de fabrica que crea una instancia de 'Pokemon' a partir de un Map (JSON)
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      // se extrae el 'id' y 'name' directamente del JSON
      id: json['id'],
      name: json['name'],
      // se extrae la lista de tipos:
      // - se convierte el valor de 'types' a una lista
      // - se mapea cada elemento, extrayendo el nombre del tipo de la estructura anidada
      // - se genera una lista de Strings a partir de estos valores
      types:
          (json['types'] as List)
              .map((type) => type['type']['name'] as String)
              .toList(),
      // se extrae la URL de la imagen oficial del Pokémon desde la ruta anidada en el JSON
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
    );
  }
}
