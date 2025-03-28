// se importan los paquetes necesarios
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokeapi/screens/login_screen.dart';

// se define un widget con estado para la pantalla de registro
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterState();
}

// estado asociado a RegisterPage donde se gestionan los datos validaciones y la lógica de registro
class _RegisterState extends State<RegisterPage> {
  // clave para identificar y validar el formulario
  final _formKey = GlobalKey<FormState>();
  // instancia de FirebaseAuth para realizar operaciones de registro
  final _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
  String _error = '';
  // bandera para indicar si se está realizando una operación en segundo plano (spinner de carga)
  bool _isLoading = false;

  // función asincrona que gestiona el registro de un nuevo usuario
  Future<void> _handleRegister() async {
    // Valida el formulario, si no es valido no continua
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // se guardan los valores ingresados en el formulario
      _formKey.currentState!.save();
      // se crea un nuevo usuario con el correo y la contraseña
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      // se envia un correo de verificacion al usuario recien creado
      await userCredential.user!.sendEmailVerification();

      // se redirige al usuario a la pantalla de login eliminando las rutas anteriores
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
      // en caso de error en la autenticación, se obtiene y muestra un mensaje de error amigable
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _getErrorMessage(e.code));
    } catch (e) {
      setState(() => _error = 'Error desconocido: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está en uso';
      case 'invalid-email':
        return 'Formato de email inválido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'Contraseña débil';
      default:
        return 'Error en el registro';
    }
  }

  // Construcción de la interfaz de la pantalla de registro
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // boton de retroceso para volver a la pantalla anterior.
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        // SingleChildScrollView permite desplazar la pantalla en dispositivos con espacio limitado
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Crea una cuenta nueva',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              // formulario que contiene los campos de entrada y boton para registrarse
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // campo de entrada para el correo electronico
                    _EmailInput(onSaved: (value) => _email = value!),
                    const SizedBox(height: 20),
                    // campo de entrada para la contraseña
                    _PasswordInput(onSaved: (value) => _password = value!),
                    const SizedBox(height: 20),
                    if (_error.isNotEmpty)
                      Text(_error, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    _RegisterButton(
                      // boton para ejecutar el registro
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// widget que define el campo de entrada para el correo electronico
class _EmailInput extends StatelessWidget {
  final FormFieldSetter<String> onSaved;

  const _EmailInput({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Correo electrónico',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      // valida que el campo no esté vacío y que contenga un '@'
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Campo obligatorio';
        if (!value!.contains('@')) return 'Correo inválido';
        return null;
      },
      //guarda el valor ingresado en el formulario
      onSaved: onSaved,
    );
  }
}

// widget que define el campo de entrada para la contraseña
class _PasswordInput extends StatelessWidget {
  final FormFieldSetter<String> onSaved;

  const _PasswordInput({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Contraseña',
        border: OutlineInputBorder(),
      ),
      // se ocultan los caracteres para mayor seguridad
      obscureText: true,
      validator: (value) => value?.isEmpty ?? true ? 'Campo obligatorio' : null,
      onSaved: onSaved,
    );
  }
}

// widget que define el botón para registrarse
class _RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _RegisterButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1877F2);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // configura el estilo visual del boton
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        // deshabilita el botón si se está en proceso de carga
        onPressed: isLoading ? null : onPressed,
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Registrarse'),
      ),
    );
  }
}
