// se importan los paquetes necesarios
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokeapi/screens/login_screen.dart';

// Función principal de la aplicación.
void main() async {
  // asegura que los widgets de Flutter esten inicializados antes de ejecutar codigo asincrono
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // inicia la aplicacion pasando el widget principal
  runApp(MyApp());
}

// widget principal de la aplicacion definido como StatefulWidget para poder gestionar estados si es necesario
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State createState() {
    return _MyAppState();
  }
}

// estado asociado a MyApp
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // se construye el widget MaterialApp que envuelve la configuración general de la aplicacion
    return MaterialApp(
      title: "Prototipo Flutter",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: LoginPage(),
    );
  }
}
