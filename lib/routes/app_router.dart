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
import '../database/models/transaction.dart';
import '../widgets/main_scaffold.dart';

final GoRouter appRouter = GoRouter(
  routes: [
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
      builder: (context, state) => const IncomeFormScreen(),
    ),
    GoRoute(
      path: '/expense',
      builder: (context, state) => const ExpenseFormScreen(),
    ),
    GoRoute(
      path: '/transfer',
      builder: (context, state) => const TransferFormScreen(),
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
        final transactionId = state.pathParameters['id'];
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

