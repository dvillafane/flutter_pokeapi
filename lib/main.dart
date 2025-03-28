// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_pokeapi/screens/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/noti_service.dart';
import 'services/token_service.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

void main() async {
  // Asegurarse de que Flutter esté completamente inicializado.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con las opciones correspondientes a la plataforma actual.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configura In-App Messaging.
  FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);

  // Inicializa el servicio de notificaciones locales.
  await initializeNotifications();

  // Configura el manejo de mensajes en segundo plano.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicia la aplicación.
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Obtiene y envía el token FCM a Firestore.
    obtenerYEnviarTokenFCM();

    // Obtiene y envía el Firebase Installation ID a Firestore.
    obtenerYEnviarFID();

    // Escucha la renovación del token.
    listenTokenRefresh();

    // Configura los escuchadores de notificaciones en primer plano.
    setupNotificationListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Prototipo Flutter",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const LoginPage(),
    );
  }
}
