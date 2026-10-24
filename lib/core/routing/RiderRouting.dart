import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/rider/presentation/RiderHomePage/ui.dart';
import '../../features/rider/presentation/RiderMapsPage/ui.dart';
import '../../features/rider/presentation/RiderChat/ui.dart';
import '../../features/rider/presentation/RiderDashBoard/ui.dart';
import '../../features/settings/presentation/ui.dart';
import '../../shared/widgets/ChatWindow/ui.dart';

class AppRoutes {
  static const String login = '/login';
  static const String riderHome = '/riderHome';
  static const String riderMaps = '/riderMaps';
  static const String riderChat = '/riderChat';
  static const String riderDashboard = '/riderDashboard';
  static const String settings = '/settings';
  static const String chatWindow = '/chatWindow';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.riderHome:
        return MaterialPageRoute(builder: (_) => const RiderHomePage());
      case AppRoutes.riderMaps:
        return MaterialPageRoute(builder: (_) => const RiderMapsPage());
      case AppRoutes.riderChat:
        return MaterialPageRoute(builder: (_) => const RiderChat());
      case AppRoutes.riderDashboard:
        return MaterialPageRoute(builder: (_) => const RiderDashBoard());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppRoutes.chatWindow:
        final args = settings.arguments;
        final String chatTitle = (args is String && args.isNotEmpty) ? args : 'Unknown User';
        return MaterialPageRoute(builder: (_) => ChatWindow(title: chatTitle));
      default:
        return MaterialPageRoute(builder: (_) => const RiderHomePage());
    }
  }
}
