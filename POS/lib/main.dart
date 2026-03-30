import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/manager/manager_home.dart';
import 'screens/waiter/waiter_home.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool loggedIn = await AuthService.isLoggedIn();
  print("APP START, LOGGED IN: $loggedIn");

  String? role;
  if (loggedIn) {
    role = await AuthService.getRole();
    print("APP START, ROLE: $role");
  }

  runApp(MyApp(loggedIn: loggedIn, role: role));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  final String? role;

  const MyApp({required this.loggedIn, this.role, super.key});

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (!loggedIn) {
      home = LoginScreen();
    } else {
      if (role == 'manager') {
        home = ManagerHome();
      } else {
        home = WaiterHome();
      }
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) =>
          loggedIn ? (role == 'manager'
              ? ManagerHome()
              : WaiterHome()) : LoginScreen(),
          '/login': (context) => LoginScreen(),
          '/manager-home': (context) => ManagerHome(),
          '/waiter-home': (context) => WaiterHome(),
        },
    );
  }
}
