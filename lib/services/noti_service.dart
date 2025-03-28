// Importaciones necesarias para el manejo de notificaciones y Firebase
import 'package:firebase_messaging/firebase_messaging.dart';  // Manejo de notificaciones push con Firebase
import 'package:flutter/foundation.dart';                      // Utilidades de depuración y constantes
import 'package:flutter_local_notifications/flutter_local_notifications.dart';  // Notificaciones locales en Android e iOS
import 'package:firebase_core/firebase_core.dart';              // Inicialización de Firebase
import '../firebase_options.dart';                              // Archivo de opciones de Firebase autogenerado

/// Instancia global para manejar notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Inicializa las notificaciones locales
Future<void> initializeNotifications() async {
  // Configuración específica para Android: usa el ícono de la aplicación como ícono de la notificación
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  // Configuración general de inicialización de notificaciones
  const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
      );

  // Inicializa el plugin de notificaciones locales con la configuración proporcionada
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

/// Manejador de notificaciones en segundo plano
/// Este método se ejecuta cuando llega una notificación mientras la app está en segundo plano o cerrada
/// Manejador de notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print('Notificación en segundo plano: ${message.messageId}');
  }

  // Verificar que el mensaje tenga datos antes de mostrar la notificación
  if (message.data.isNotEmpty) {
    await _showLocalNotification(message);
  }
}


/// Muestra una notificación local en cualquier contexto (primer plano, segundo plano o cerrada)
Future<void> _showLocalNotification(RemoteMessage message) async {
  // Obtiene los detalles de la notificación desde el mensaje recibido
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  // Si la notificación y su configuración de Android no son nulas, procede a mostrarla
  if (notification != null && android != null) {
    // Configuración de los detalles de la notificación en Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',       // ID del canal de notificación
      'channel_name',     // Nombre del canal
      channelDescription: 'channel_description',  // Descripción del canal
      importance: Importance.max,  // Nivel de importancia (máxima prioridad)
      priority: Priority.high,     // Prioridad alta para mostrar al instante
    );

    // Detalles de la notificación combinando configuraciones de Android
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Muestra la notificación localmente en el dispositivo
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,  // ID único de la notificación
      notification.title,     // Título de la notificación
      notification.body,      // Cuerpo de la notificación
      notificationDetails,    // Configuración de la notificación
      payload: 'Notification Payload',  // Carga útil opcional para acciones posteriores
    );
  }
}

/// Obtiene el token FCM (Firebase Cloud Messaging) del dispositivo
Future<void> obtenerTokenFCM() async {
  // Instancia de Firebase Messaging para interactuar con el servicio de notificaciones
  final messaging = FirebaseMessaging.instance;

  // Solicita el token de registro del dispositivo
  String? token = await messaging.getToken();

  // Imprime el token en la consola si está en modo debug (útil para pruebas)
  if (kDebugMode) {
    print('Registration Token=$token');
  }

  // Opcional: Aquí podrías enviar el token a tu servidor o almacenarlo localmente
}

/// Configura los escuchadores para manejar notificaciones en primer plano
void setupNotificationListeners() {
  // Escucha cuando se recibe una notificación mientras la app está en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Muestra el ID de la notificación en la consola si está en modo debug
    if (kDebugMode) {
      print('Notificación en primer plano: ${message.messageId}');
    }

    // Muestra la notificación localmente
    _showLocalNotification(message);
  });

  // Solicita permisos de notificación al usuario (alertas, íconos de aplicación y sonido)
  FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}
