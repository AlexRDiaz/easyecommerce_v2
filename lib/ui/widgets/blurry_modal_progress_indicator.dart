import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LandingPage extends StatefulWidget {
  static const routeName = '/landingPage';
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: isLoading,
      blurEffectIntensity: 4,
      progressIndicator: SpinKitFadingCircle(
        color: Colors.purple,
        size: 90.0,
      ),
      dismissible: false,
      opacity: 0.4,
      color: Colors.black87,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'SIGN IN',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.060,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                'Email',
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              Text(
                'Password',
              ),
              TextField(
                controller: passwordController,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.074,
                width: MediaQuery.of(context).size.width * 0.68,
                margin: MediaQuery.of(context).size.width == 320.0
                    ? EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.09)
                    : EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.1),
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.purple,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      await Future.delayed(Duration(seconds: 6), () {
                        setState(() {
                          isLoading = !isLoading;
                        });
                      });
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'LibreBaskerville',
                        fontSize: MediaQuery.of(context).size.width * 0.056,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
