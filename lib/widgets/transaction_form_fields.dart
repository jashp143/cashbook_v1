import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/models/account.dart';
import '../database/models/contact.dart';

class TransactionFormFields {
  static Widget buildAmountField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '₹ ',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  static Widget buildAccountDropdown({
    required List<Account> accounts,
    required int? selectedAccountId,
    required Function(int?) onChanged,
    required String label,
    String? Function(int?)? validator,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: selectedAccountId,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: accounts.map((account) {
        return DropdownMenuItem<int>(
          value: account.id,
          child: Text(account.name),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  static Widget buildContactDropdown({
    required List<Contact> contacts,
    required int? selectedContactId,
    required Function(int?) onChanged,
    required String label,
    VoidCallback? onAddNew,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: selectedContactId,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('None'),
            ),
            ...contacts.map((contact) {
              return DropdownMenuItem<int>(
                value: contact.id,
                child: Text(contact.name),
              );
            }),
          ],
          onChanged: onChanged,
        ),
        if (onAddNew != null)
          TextButton.icon(
            onPressed: onAddNew,
            icon: const Icon(Icons.add),
            label: const Text('Add New Contact'),
          ),
      ],
    );
  }

  static Widget buildDateField({
    required BuildContext context,
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
    required String label,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
      ),
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }
}

