import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = true;
  bool _isTokenValid = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _token = Get.parameters['token']; // Obtén el token desde la URL
    if (_token != null) {
      _verifyToken(_token!);
    } else {
      setState(() {
        _isLoading = false;
        _isTokenValid = false;
      });
    }
  }

  Future<void> _verifyToken(String token) async {
    try {
      final response = await Connections().verifyToken(token);

      if (response != 1 && response != 2) {
        setState(() {
          _isTokenValid = true;
        });
      } else {
        setState(() {
          _isTokenValid = false;
        });
        Get.snackbar(
          "Error",
          "El token no es válido o ha expirado",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isTokenValid = false;
      });
      Get.snackbar(
        "Error",
        "Hubo un problema al verificar el token",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitNewPassword(String token) async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Por favor completa todos los campos",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Las contraseñas no coinciden",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final response = await Connections().resetPassword(
          token, _passwordController.text, _confirmPasswordController.text);

      if (response != 1 && response != 2) {
        Get.snackbar(
          "Éxito",
          "Contraseña restablecida correctamente",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed('/login');
      } else {
        Get.snackbar(
          "Error",
          "No se pudo restablecer la contraseña",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Hubo un error al intentar restablecer la contraseña",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildWaveBackground(height, width, aligment, angle) {
    return Align(
      alignment: aligment,
      child: Transform.rotate(
        angle: angle * (3.14159265359 / 180), // Convierte 65 grados a radianes
        child: ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: height, // Ajusta la altura de la ola según tus necesidades
            width: width, // Ajusta el ancho de la ola según tus necesidades
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 18, 151, 168).withOpacity(0.6),
                  const Color.fromARGB(255, 33, 175, 218).withOpacity(0.4)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isTokenValid) {
      return Scaffold(
        body: Center(
          child: Text(
            "El token no es válido o ha expirado.",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Restablecer Contraseña",
            style: TextStylesSystem().ralewayStyle(
              14,
              FontWeight.w500,
              Colors.white,
            ),
          ),
          backgroundColor: ColorsSystem().colorPrincipalBrand,
        ),
        body: SafeArea(
            child: Stack(children: [
          _buildWaveBackground(1200, 2000, Alignment.bottomRight, 125),
          _buildWaveBackground(2000, 1200, Alignment.bottomRight, -55),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Restablece tu contraseña",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorsSystem().colorStore,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "Nueva contraseña",
                          labelText: "Nueva Contraseña",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: "Confirma tu contraseña",
                          labelText: "Confirmar Contraseña",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => _submitNewPassword(_token!),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Restablecer Contraseña",
                          style: TextStylesSystem().ralewayStyle(
                            16,
                            FontWeight.w600,
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ])));
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - 100); // Ajusta la altura de la ola
    final firstControlPoint = Offset(size.width / 3, size.height);
    final firstEndPoint = Offset(
        size.width / 2.25, size.height - 80); // Ajusta la forma de la ola
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    final secondControlPoint = Offset(size.width - (size.width / 3),
        size.height - 120); // Ajusta la forma de la ola
    final secondEndPoint =
        Offset(size.width, size.height - 100); // Ajusta la forma de la ola
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
