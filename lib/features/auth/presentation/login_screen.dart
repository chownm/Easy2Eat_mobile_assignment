import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import '../../../services/firebase/auth_service.dart';
import 'loginButton.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.googleSignIn();
      if (success && mounted) {
        final role = UserSession.role;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In successful!'),
            backgroundColor: ThemesColors.success,
          ),
        );

        if (role == 'rider') {
          Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.brandOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'lib/assets/images/Easy2Eat_Logo.jpg',
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      bottomSheet: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.90,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: ThemesColors.appSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle indicator
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      const Text(
                        "Sign up or log in",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ThemesColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "SIGN UP TO GET YOUR DISCOUNT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(color: ThemesColors.brandOrange),
                          ),
                        )
                      else
                        LoginButton.google(onPressed: _handleGoogleSignIn),
                      const SizedBox(height: 12),
                      LoginButton.email(
                        label: "Log In with Email",
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.emailLogin);
                        },
                      ),
                      const SizedBox(height: 12),
                      LoginButton.email(
                        label: "Sign Up with Email",
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.emailSignup);
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              children: const [
                                TextSpan(text: "By signing up you agree to our "),
                                TextSpan(
                                  text: "Terms and Conditions",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                    color: ThemesColors.brandOrange,
                                  ),
                                ),
                                TextSpan(text: " and "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                    color: ThemesColors.brandOrange,
                                  ),
                                ),
                                TextSpan(text: "."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
