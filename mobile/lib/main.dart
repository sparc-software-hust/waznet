import 'package:cecr_unwomen/features/authentication/view/login_screen.dart';
import 'package:cecr_unwomen/screens/home_screen_fcase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/authentication/authentication.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const App(),
      theme: ThemeData(fontFamily: 'Satoshi'),
      // localizationsDelegates: [
      //   S.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   Locale('en'), // English
      //   Locale('vi'),
      // ],
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc(),
      child: const BlocEntireApp()
    );
  }
}

class BlocEntireApp extends StatefulWidget {
  const BlocEntireApp({super.key});

  @override
  State<BlocEntireApp> createState() => _BlocEntireAppState();
}

class _BlocEntireAppState extends State<BlocEntireApp> {
  @override
  void initState() {
    context.read<AuthenticationBloc>().add(CheckAutoLogin());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        debugPrint("State:$state");
        if (state.status == AuthenticationStatus.authorized) {
          return const HomeScreen();
        } else if (state.status == AuthenticationStatus.loading) {
          return const CircularProgressIndicator();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
