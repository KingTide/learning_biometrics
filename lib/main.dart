import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LearningBiometrics();
  }
}

class LearningBiometrics extends StatefulWidget {
  const LearningBiometrics({Key? key}) : super(key: key);

  @override
  State<LearningBiometrics> createState() => _LearningBiometricsState();
}

class _LearningBiometricsState extends State<LearningBiometrics> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticated = false;

  Future<void> authenticateBio() async {
    final bool canAuthenticateWithBio = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBio || await auth.isDeviceSupported();

    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      debugPrint('Biometrics detected');
    }

    if (availableBiometrics.contains(BiometricType.face)) {
      debugPrint('Face biometrics detected');
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      debugPrint('Touch biometrics detected');
    }

    if (availableBiometrics.contains(BiometricType.strong)) {
      debugPrint('Strong biometrics available');
    }

    try {
      final bool isAuthenticationCompleted = await auth.authenticate(
          options: const AuthenticationOptions(
              useErrorDialogs: false,
              sensitiveTransaction: true,
              stickyAuth: true,
              biometricOnly: true),
          localizedReason: 'Please give me your biometric authentication');
      setState(() {
        isAuthenticated = isAuthenticationCompleted;
      });
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        debugPrint('no biometrics available');
      }

      if (e.code == auth_error.notEnrolled) {
        debugPrint('Biometrics not enrolled');
      }

      if (e.code == auth_error.lockedOut) {
        debugPrint('WHAT ARE YOU DOING?');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(brightness: Brightness.light),
        home: CupertinoPageScaffold(
          backgroundColor: isAuthenticated
              ? CupertinoColors.activeGreen
              : CupertinoColors.activeOrange,
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Biometrics'),
          ),
          child: SafeArea(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  onPressed: () => {authenticateBio()},
                  child: const Text(
                    'Authenticate!',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      isAuthenticated = false;
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                )
              ],
            )),
          ),
        ));
  }
}
