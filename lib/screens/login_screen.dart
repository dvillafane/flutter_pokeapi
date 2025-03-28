// se importan los paquetes necesarios
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokeapi/screens/home_screen.dart';
import 'package:flutter_pokeapi/screens/register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_button/sign_button.dart';
import 'forgot_password_screen.dart';

// se define un widget con estado para la pantalla de login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

// estado asociado a LoginPage donde se gestionan los datos y la logica de autenticacion
class _LoginState extends State<LoginPage> {
  // clave para identificar y validar el formulario
  final _formKey = GlobalKey<FormState>();
  // instancia de FirebaseAuth para realizar las operaciones de autenticacion
  final _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
  String _error = '';
  // bandera para indicar si se está realizando una operación en segundo plano (spinner de carga)
  bool _isLoading = false;

  // Funcion para gestionar el inicio de sesion con correo y contraseña
  Future<void> _handleLogin() async {
    // Valida el formulario, si no es valido no continua
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // guarda los valores ingresados en el formulario
      _formKey.currentState!.save();
      // intenta iniciar sesion con Firebase.
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // verifica si el usuario tiene el correo verificado.
      if (userCredential.user?.emailVerified ?? false) {
        // si está verificado navega a la pantalla principal y elimina las rutas previas
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage()),
          (route) => false,
        );
      } else {
        // si el correo no está verificado se muestra un mensaje de erro
        setState(() => _error = 'Por favor verifica tu correo electrónico');
      }
    } on FirebaseAuthException catch (e) {
      // en caso de error de autenticacion se actualiza el mensaje de error segun el codigo
      setState(() => _error = _getErrorMessage(e.code));
    } catch (e) {
      setState(() => _error = 'Error desconocido: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // funcion para iniciar sesión con google.
  Future<UserCredential> _signInWithGoogle() async {
    // se abre la ventana de seleccion de cuenta google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // se obtiene la autenticacion de la cuenta seleccionada
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // se generan las credenciales necesarias para firebase
    final AuthCredential credentials = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // se realiza el inicio de sesion con las credenciales obtenidas
    return await FirebaseAuth.instance.signInWithCredential(credentials);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Formato de email inválido';
      case 'user-disabled':
        return 'Cuenta deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación';
    }
  }

  // construccion de la interfaz de la pantalla de login
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE3F2FD);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        // se utiliza SingleChildScrollView para hacer la pantalla desplazable en dispositivos pequeños
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // titulo de la aplicación.
              Text(
                "Prototipo Flutter",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // formulario de inicio de sesion
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
                    // boton para iniciar sesion con indicador de carga si es necesario
                    _LoginButton(
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // boton para navegar a la pantalla de recuperacion de contraseña
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.black54),
                child: const Text('¿Has olvidado la contrasena?'),
              ),
              const SizedBox(height: 40),
              // boton para navegar a la pantalla de registro de cuenta
              _CreateAccountButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              // boton de inicio de sesión con google
              SignInButton(
                buttonType: ButtonType.google,
                onPressed: () async {
                  // realiza la autenticación con google
                  await _signInWithGoogle();
                  // si el usuario se autentico correctamente se navega a la pantalla principal
                  if (FirebaseAuth.instance.currentUser != null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// widget para el campo de entrada del correo electronico
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
      // tipo de teclado específico para emails
      keyboardType: TextInputType.emailAddress,
      // validación para asegurar que el campo no esté vacio y tenga formato de email
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Campo obligatorio';
        if (!value!.contains('@')) return 'Email inválido';
        return null;
      },
      // guarda el valor ingresado
      onSaved: onSaved,
    );
  }
}

// widget para el campo de entrada de la contraseña
class _PasswordInput extends StatelessWidget {
  final FormFieldSetter<String> onSaved;

  const _PasswordInput({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // configuracion visual
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Contraseña',
        border: OutlineInputBorder(),
      ),
      // se ocultan los caracteres para seguridad
      obscureText: true,
      validator: (value) => value?.isEmpty ?? true ? 'Campo obligatorio' : null,
      onSaved: onSaved,
    );
  }
}

// widget para el boton de inicio de sesion
class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

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
        // deshabilita el boton si se está cargando
        onPressed: isLoading ? null : onPressed,
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Iniciar sesión'),
      ),
    );
  }
}

// Widget para el botón de creacion de una nueva cuenta
class _CreateAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateAccountButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // se configura el estilo del boton con borde y tamaño minimo
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.blueAccent),
      ),
      // al presionar navega a la pantalla de registro
      onPressed: onPressed,
      child: const Text(
        'Crear cuenta nueva',
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }
}
