// se importan los paquetes necesarios
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// se define un widget sin estado para la pantalla de recuperación de contraseña
class ForgotPasswordScreen extends StatelessWidget {
  // controlador para manejar el campo de texto donde se ingresa el correo
  final TextEditingController emailController = TextEditingController();

  // constructor del widget
  ForgotPasswordScreen({super.key});

  // funcion asincrona que intenta enviar un correo para restablecer la contraseña
  Future<void> _resetPassword(BuildContext context) async {
    // se obtiene y limpia el correo ingresado
    final String email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor ingresa un correo electrónico")),
      );
      return;
    }

    try {
      // se solicita a Firebase el envío del correo de restablecimiento
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // si se envía correctamente se notifica al usuario con un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Se ha enviado un enlace de recuperación a tu correo")),
      );
    } catch (e) {
      // si ocurre algún error se muestra el error en un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  // Método build que construye la interfaz de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // boton de retroceso para volver a la pantalla anterior.
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Recupera tu cuenta",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Ingresa tu dirección de correo electrónico.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            // campo de texto para ingresar el correo electronico
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Correo electrónico",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // boton para continuar con el proceso de recuperacion
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _resetPassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Continuar",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE3F2FD),
    );
  }
}
