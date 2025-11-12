import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycashbook2/l10n/app_localizations.dart';
import '../../providers/account_provider.dart';
import '../../database/models/account.dart';

class AccountFormScreen extends StatefulWidget {
  final String? accountId;
  const AccountFormScreen({super.key, this.accountId});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  Account? _existingAccount;

  @override
  void initState() {
    super.initState();
    if (widget.accountId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAccount();
      });
    }
  }

  Future<void> _loadAccount() async {
    final accountProvider = context.read<AccountProvider>();
    await accountProvider.loadAccounts();
    final account = accountProvider.getAccountById(int.parse(widget.accountId!));
    if (account != null) {
      setState(() {
        _existingAccount = account;
        _nameController.text = account.name;
        _accountNumberController.text = account.accountNumber ?? '';
        _noteController.text = account.note ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now().toIso8601String();
      final account = Account(
        id: _existingAccount?.id,
        name: _nameController.text.trim(),
        balance: _existingAccount?.balance ?? 0.0,
        accountNumber: _accountNumberController.text.trim().isEmpty
            ? null
            : _accountNumberController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: _existingAccount?.createdAt ?? now,
      );

      if (_existingAccount == null) {
        await context.read<AccountProvider>().addAccount(account);
      } else {
        await context.read<AccountProvider>().updateAccount(account);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Fluttertoast.showToast(
          msg: _existingAccount == null
              ? l10n.accountCreated
              : l10n.accountUpdated,
          toastLength: Toast.LENGTH_SHORT,
        );
        context.go('/accounts');
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.error(e.toString()),
          toastLength: Toast.LENGTH_SHORT,
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
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/accounts');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_existingAccount == null 
              ? AppLocalizations.of(context)!.newAccount 
              : AppLocalizations.of(context)!.editAccount),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/accounts'),
          ),
        ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.accountName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterAccountName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumberController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.accountNumberOptional,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.noteOptional,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAccount,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context)!.saveAccount),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
