// Importaciones necesarias para la aplicación en Flutter
import 'package:flutter/material.dart'; // Paquete de Flutter para construir la interfaz de usuario.
import 'package:firebase_core/firebase_core.dart'; // Paquete para inicializar Firebase en la aplicación.
import 'firebase_options.dart'; // Archivo generado automáticamente con la configuración de Firebase.
import 'package:flutter_pokeapi/screens/login_screen.dart'; // Pantalla de inicio de sesión de la aplicación.
import 'package:firebase_messaging/firebase_messaging.dart'; // Paquete para manejar notificaciones push con Firebase.
import 'services/noti_service.dart'; // Servicio personalizado para manejar notificaciones.
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart'; // Paquete para manejar nensajes in-app con Firebase.

void main() async {
  // Asegurarse de que el framework de Flutter esté completamente inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones de la plataforma actual
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa In-App Messaging
  FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);

  // Inicializar el servicio de notificaciones
  await initializeNotifications();

  // Configurar el manejo de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Iniciar la aplicación con el widget raíz MyApp
  runApp(const MyApp());
}

// Definición del widget principal de la aplicación
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// Estado asociado al widget principal MyApp
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Obtener el token de Firebase Cloud Messaging (FCM) para recibir notificaciones
    obtenerTokenFCM();
    // Obtener el Firebase Installation ID para recibir notificaciones in-app
    obtenerFID();

    // Configurar los escuchadores para manejar las notificaciones entrantes
    setupNotificationListeners();
  }

  @override
  Widget build(BuildContext context) {
    // Construir la interfaz de usuario de la aplicación
    return MaterialApp(
      title: "Prototipo Flutter", // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema de la aplicación con el color azul
        useMaterial3: false, // Deshabilitar el uso de Material 3
      ),
      home:
          const LoginPage(), // Página de inicio que muestra la pantalla de inicio de sesión
    );
  }
}
