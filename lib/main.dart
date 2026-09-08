import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'data/repositories/app_repository.dart';
import 'app_view_model.dart';
import 'ui/shared_widgets/bottom_nav_bar.dart';
import 'ui/features/onboarding/language_selection_screen.dart';
import 'ui/features/onboarding/login_screen.dart';
import 'ui/features/onboarding/phone_verification_screen.dart';
import 'ui/features/marketplace/marketplace_home_screen.dart';
import 'ui/features/bookings_list/my_bookings_screen.dart';
import 'ui/features/profile/profile_settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = AppRepository();
  final viewModel = AppViewModel(repository: repository);
  runApp(WorkSoluteApp(viewModel: viewModel));
}

class WorkSoluteApp extends StatelessWidget {
  final AppViewModel viewModel;

  const WorkSoluteApp({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'Work Solute Cooperative Home Services',
          debugShowCheckedModeBanner: false,
          theme: CooperativeTheme.lightTheme,
          home: _buildScreen(viewModel.currentScreen),
        );
      },
    );
  }

  Widget _buildScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.languageSelection:
        return LanguageSelectionScreen(viewModel: viewModel);
      case AppScreen.login:
        return LoginScreen(viewModel: viewModel);
      case AppScreen.phoneVerification:
        return PhoneVerificationScreen(viewModel: viewModel);
      case AppScreen.mainShell:
        return MainShell(viewModel: viewModel);
    }
  }
}

typedef SahayakApp = WorkSoluteApp;

class MainShell extends StatelessWidget {
  final AppViewModel viewModel;

  const MainShell({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTabBody(viewModel.currentTab),
      bottomNavigationBar: CooperativeBottomNavBar(
        viewModel: viewModel,
      ),
    );
  }

  Widget _buildTabBody(ShellTab tab) {
    switch (tab) {
      case ShellTab.home:
        return MarketplaceHomeScreen(viewModel: viewModel);
      case ShellTab.bookings:
        return MyBookingsScreen(
          viewModel: viewModel,
          repository: viewModel.repository,
          onBookService: () => viewModel.switchTab(ShellTab.home),
        );
      case ShellTab.profile:
        return ProfileSettingsScreen(
          viewModel: viewModel,
          onLogout: () => viewModel.navigateTo(AppScreen.login),
        );
    }
  }
}
