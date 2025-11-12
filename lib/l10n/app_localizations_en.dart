// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Khata Vahi';

  @override
  String get home => 'Home';

  @override
  String get reports => 'Reports';

  @override
  String get accounts => 'Accounts';

  @override
  String get contacts => 'Contacts';

  @override
  String get settings => 'Settings';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get allAccounts => 'All Accounts';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get addYourFirstTransaction => 'Add your first transaction';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String deleteTransactionConfirmation(String type, String amount) {
    return 'Are you sure you want to delete this $type transaction of ₹$amount?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get transactionDeletedSuccessfully =>
      'Transaction deleted successfully';

  @override
  String errorDeletingTransaction(String error) {
    return 'Error deleting transaction: $error';
  }

  @override
  String get edit => 'Edit';

  @override
  String get date => 'Date';

  @override
  String get account => 'Account';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get contact => 'Contact';

  @override
  String get billNumber => 'Bill Number';

  @override
  String get company => 'Company';

  @override
  String get remark => 'Remark';

  @override
  String get shareViaWhatsApp => 'Share via WhatsApp';

  @override
  String get couldNotOpenWhatsApp =>
      'Could not open WhatsApp. Please make sure WhatsApp is installed.';

  @override
  String get chooseHowToShare => 'Choose how to share:';

  @override
  String get withPhoneNumber => 'With Phone Number';

  @override
  String get withoutPhoneNumber => 'Without Phone Number';

  @override
  String get phone => 'Phone';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get gujarati => 'Gujarati';

  @override
  String get incomeLabel => 'INCOME';

  @override
  String get expenseLabel => 'EXPENSE';

  @override
  String get transferLabel => 'TRANSFER';

  @override
  String get accountStatement => 'Account Statement';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get exportPDF => 'Export PDF';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get pleaseSelectAccountAndDateRange =>
      'Please select account and date range';

  @override
  String get pdfExportedSuccessfully => 'PDF exported successfully';

  @override
  String errorExportingPDF(String error) {
    return 'Error exporting PDF: $error';
  }

  @override
  String get excelExportedSuccessfully => 'Excel exported successfully';

  @override
  String errorExportingExcel(String error) {
    return 'Error exporting Excel: $error';
  }

  @override
  String get accountBalance => 'Account Balance';

  @override
  String get net => 'Net';

  @override
  String get selectAccountToViewStatement =>
      'Select an account to view statement';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get forSelectedDateRange => 'for the selected date range';

  @override
  String get newAccount => 'New Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get accountName => 'Account Name';

  @override
  String get pleaseEnterAccountName => 'Please enter account name';

  @override
  String get accountNumberOptional => 'Account Number (Optional)';

  @override
  String get noteOptional => 'Note (Optional)';

  @override
  String get saveAccount => 'Save Account';

  @override
  String get accountCreated => 'Account created';

  @override
  String get accountUpdated => 'Account updated';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get noAccountsFound => 'No accounts found';

  @override
  String get addAccount => 'Add Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String deleteAccountConfirmation(String accountName) {
    return 'Are you sure you want to delete \"$accountName\"?';
  }

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get newContact => 'New Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get name => 'Name';

  @override
  String get pleaseEnterName => 'Please enter name';

  @override
  String get phoneOptional => 'Phone (Optional)';

  @override
  String get emailOptional => 'Email (Optional)';

  @override
  String get importFromDevice => 'Import from Device';

  @override
  String get saveContact => 'Save Contact';

  @override
  String get contactCreated => 'Contact created';

  @override
  String get contactUpdated => 'Contact updated';

  @override
  String get contactPermissionRequired =>
      'Contact permission is required to import contacts';

  @override
  String get noContactsFoundOnDevice => 'No contacts found on device';

  @override
  String get selectContact => 'Select Contact';

  @override
  String errorImportingContact(String error) {
    return 'Error importing contact: $error';
  }

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String get addContact => 'Add Contact';

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String deleteContactConfirmation(String contactName) {
    return 'Are you sure you want to delete \"$contactName\"?';
  }

  @override
  String get contactDeleted => 'Contact deleted';

  @override
  String get amount => 'Amount';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get expenseAccountNote =>
      'The selected account will be debited for the expense';

  @override
  String get expenseContactNote =>
      'To which contact you paid the expense. If not, select None';

  @override
  String get pleaseSelectAnAccount => 'Please select an account';

  @override
  String get billNumberOptional => 'Bill Number (Optional)';

  @override
  String get companyNameOptional => 'Company Name (Optional)';

  @override
  String get remarkOptional => 'Remark (Optional)';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get expenseUpdatedSuccessfully => 'Expense updated successfully';

  @override
  String get expenseAddedSuccessfully => 'Expense added successfully';

  @override
  String get addIncome => 'Add Income';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get incomeAccountNote =>
      'The selected account will receive the income';

  @override
  String get incomeContactNote =>
      'From which contact you received income. If not, select None';

  @override
  String get updateIncome => 'Update Income';

  @override
  String get saveIncome => 'Save Income';

  @override
  String get incomeUpdatedSuccessfully => 'Income updated successfully';

  @override
  String get incomeAddedSuccessfully => 'Income added successfully';

  @override
  String get editTransfer => 'Edit Transfer';

  @override
  String get pleaseSelectBothAccounts => 'Please select both accounts';

  @override
  String get fromAndToAccountsMustBeDifferent =>
      'From and To accounts must be different';

  @override
  String get pleaseSelectFromAccount => 'Please select from account';

  @override
  String get pleaseSelectToAccount => 'Please select to account';

  @override
  String get updateTransfer => 'Update Transfer';

  @override
  String get completeTransfer => 'Complete Transfer';

  @override
  String get transferUpdatedSuccessfully => 'Transfer updated successfully';

  @override
  String get transferCompletedSuccessfully => 'Transfer completed successfully';

  @override
  String get withPhoneNumberDescription =>
      '• With phone number: Opens chat directly (if number is on WhatsApp)';

  @override
  String get withoutPhoneNumberDescription =>
      '• Without phone number: Opens WhatsApp, you can select the contact';

  @override
  String get filters => 'Filters';

  @override
  String get timeline => 'Timeline';

  @override
  String get calendar => 'Calendar';

  @override
  String get allContacts => 'All Contacts';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get transactionReport => 'Transaction Report';

  @override
  String get hideCalendar => 'Hide Calendar';

  @override
  String get showCalendar => 'Show Calendar';

  @override
  String get noTransactions => 'No transactions';

  @override
  String noTransactionsOnDate(String date) {
    return 'No transactions on $date';
  }

  @override
  String transactionCount(int count) {
    return '$count transaction';
  }

  @override
  String transactionCountPlural(int count) {
    return '$count transactions';
  }

  @override
  String netLabel(String amount) {
    return 'Net: ₹$amount';
  }

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get whatsAppNotRegisteredMessage =>
      'If WhatsApp says the number isn\'t registered, try sharing without phone number option.';

  @override
  String get receipts => 'Receipts';

  @override
  String get addReceipt => 'Add Receipt';

  @override
  String get noReceiptsAdded => 'No receipts added';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get pickPDFFile => 'Pick PDF File';

  @override
  String errorPickingImage(String error) {
    return 'Error picking image: $error';
  }

  @override
  String errorPickingPDF(String error) {
    return 'Error picking PDF: $error';
  }

  @override
  String get previewReceipt => 'Preview Receipt';

  @override
  String get removeReceipt => 'Remove Receipt';
}
