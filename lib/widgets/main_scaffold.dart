import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'bottom_nav_bar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  int _getCurrentIndex(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/reports':
        return 1;
      case '/accounts':
        return 2;
      case '/contacts':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(currentRoute);
    final shouldShowBottomNav = ['/', '/reports', '/accounts', '/contacts']
        .contains(currentRoute);

    // Wrap with PopScope for root routes to handle back button
    Widget scaffold = Scaffold(
      body: child,
      bottomNavigationBar: shouldShowBottomNav
          ? CustomBottomNavBar(currentIndex: currentIndex)
          : null,
    );

    // Add back button handling for root routes
    if (shouldShowBottomNav) {
      scaffold = PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            // Show exit confirmation for root routes
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Do you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
            
            if (shouldExit == true) {
              SystemNavigator.pop();
            }
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}

