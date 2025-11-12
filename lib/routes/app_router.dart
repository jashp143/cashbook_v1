import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/income/income_form_screen.dart';
import '../screens/expense/expense_form_screen.dart';
import '../screens/transfer/transfer_form_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/accounts/account_list_screen.dart';
import '../screens/accounts/account_form_screen.dart';
import '../screens/contacts/contact_list_screen.dart';
import '../screens/contacts/contact_form_screen.dart';
import '../screens/transactions/transaction_detail_screen.dart';
import '../screens/account_statement/account_statement_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../utils/onboarding_helper.dart';
import '../database/models/transaction.dart';
import '../widgets/main_scaffold.dart';

// Flag to track if splash should be shown on app startup
bool _shouldShowSplashOnStartup = true;
// Flag to track if we just navigated from splash (to prevent redirect loop)
bool _justNavigatedFromSplash = false;

// Function to mark that we're navigating from splash screen
void markNavigatingFromSplash() {
  _justNavigatedFromSplash = true;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final isOnboardingComplete = await OnboardingHelper.isOnboardingComplete();
    final currentPath = state.uri.path;

    // If we just navigated from splash to home, don't redirect back
    if (_justNavigatedFromSplash && currentPath == '/') {
      _justNavigatedFromSplash = false;
      return null; // Allow navigation to home
    }

    // If onboarding is not complete and not already on welcome screen, redirect to welcome
    if (!isOnboardingComplete && currentPath != '/welcome') {
      return '/welcome';
    }

    // If onboarding is complete and on welcome screen, redirect to splash
    if (isOnboardingComplete && currentPath == '/welcome') {
      return '/splash';
    }

    // On initial app load (root path), show splash if onboarding is complete
    // Only redirect on the very first navigation to prevent loops
    if (currentPath == '/' && isOnboardingComplete && _shouldShowSplashOnStartup) {
      _shouldShowSplashOnStartup = false; // Mark that we've shown it for this session
      return '/splash';
    }

    return null; // No redirect needed
  },
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(
          currentRoute: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AccountListScreen(),
        ),
        GoRoute(
          path: '/contacts',
          builder: (context, state) => const ContactListScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/income',
      builder: (context, state) {
        final transaction = state.extra as Transaction?;
        return IncomeFormScreen(transactionToEdit: transaction);
      },
    ),
    GoRoute(
      path: '/expense',
      builder: (context, state) {
        final transaction = state.extra as Transaction?;
        return ExpenseFormScreen(transactionToEdit: transaction);
      },
    ),
    GoRoute(
      path: '/transfer',
      builder: (context, state) {
        final transaction = state.extra as Transaction?;
        return TransferFormScreen(transactionToEdit: transaction);
      },
    ),
    GoRoute(
      path: '/accounts/new',
      builder: (context, state) => const AccountFormScreen(),
    ),
    GoRoute(
      path: '/accounts/:id',
      builder: (context, state) {
        final accountId = state.pathParameters['id'];
        return AccountFormScreen(accountId: accountId);
      },
    ),
    GoRoute(
      path: '/contacts/new',
      builder: (context, state) => const ContactFormScreen(),
    ),
    GoRoute(
      path: '/contacts/:id',
      builder: (context, state) {
        final contactId = state.pathParameters['id'];
        return ContactFormScreen(contactId: contactId);
      },
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) {
        final transaction = state.extra as Transaction?;
        if (transaction != null) {
          return TransactionDetailScreen(transaction: transaction);
        }
        // Fallback - should not happen if navigation is correct
        return const Scaffold(
          body: Center(child: Text('Transaction not found')),
        );
      },
    ),
    GoRoute(
      path: '/account-statement',
      builder: (context, state) => const AccountStatementScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

