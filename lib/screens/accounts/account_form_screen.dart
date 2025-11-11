import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        createdAt: _existingAccount?.createdAt ?? now,
      );

      if (_existingAccount == null) {
        await context.read<AccountProvider>().addAccount(account);
      } else {
        await context.read<AccountProvider>().updateAccount(account);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingAccount == null
                ? 'Account created'
                : 'Account updated'),
          ),
        );
        context.go('/accounts');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          title: Text(_existingAccount == null ? 'New Account' : 'Edit Account'),
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
              decoration: const InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter account name';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAccount,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Account'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
