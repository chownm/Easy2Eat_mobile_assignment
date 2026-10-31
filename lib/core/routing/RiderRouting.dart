import 'package:flutter/material.dart';
import '../../core/constants/active_delivery.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/email_login_screen.dart';
import '../../features/auth/presentation/email_signup_screen.dart';
import '../../features/rider/presentation/RiderHomePage/ui.dart';
import '../../features/rider/presentation/RiderMapsPage/ui.dart';
import '../../features/rider/presentation/RiderChat/ui.dart';
import '../../features/rider/presentation/RiderDashBoard/ui.dart';
import '../../features/rider/presentation/RiderSetting/ui.dart';
import '../../shared/widgets/ChatWindow/ui.dart';
import '../../shared/widgets/settings/presentation/ProfileDetails.dart';

class AppRoutes {
  static const String login = '/login';
  static const String emailLogin = '/emailLogin';
  static const String emailSignup = '/emailSignup';
  static const String riderHome = '/riderHome';
  static const String riderMaps = '/riderMaps';
  static const String riderChat = '/riderChat';
  static const String riderDashboard = '/riderDashboard';
  static const String settings = '/settings';
  static const String chatWindow = '/chatWindow';
  static const String profileDetails = '/profileDetails';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.emailLogin:
        return MaterialPageRoute(builder: (_) => const EmailLoginPage());
      case AppRoutes.emailSignup:
        return MaterialPageRoute(builder: (_) => const EmailSignupPage());
      case AppRoutes.riderHome:
        return MaterialPageRoute(builder: (_) => const RiderHomePage());
      case AppRoutes.riderMaps:
        final args = settings.arguments;
        final String deliveryNumber = (args is String && args.isNotEmpty && args != 'Unknown Delivery')
            ? args
            : ActiveDeliveryState.latestViewedRoute;
        return MaterialPageRoute(builder: (_) => RiderMapsPage(deliveryNumber: deliveryNumber));
      case AppRoutes.riderChat:
        return MaterialPageRoute(builder: (_) => const RiderChat());
      case AppRoutes.riderDashboard:
        return MaterialPageRoute(builder: (_) => const RiderDashBoard());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const RiderSettingPage());
      case AppRoutes.profileDetails:
        return MaterialPageRoute(builder: (_) => const ProfileDetailsPage());
      case AppRoutes.chatWindow:
        final chatTitle = settings.arguments as String? ?? 'Customer';

        return MaterialPageRoute(
          builder: (context) => ChatWindow(
            title: chatTitle,
            subtitle: 'Active Order • On Delivery',
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const RiderHomePage());
    }
  }
}
