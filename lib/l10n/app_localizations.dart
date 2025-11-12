import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Khata Vahi'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @allAccounts.
  ///
  /// In en, this message translates to:
  /// **'All Accounts'**
  String get allAccounts;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @addYourFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction'**
  String get addYourFirstTransaction;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {type} transaction of ₹{amount}?'**
  String deleteTransactionConfirmation(String type, String amount);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @transactionDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccessfully;

  /// No description provided for @errorDeletingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Error deleting transaction: {error}'**
  String errorDeletingTransaction(String error);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccount;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @billNumber.
  ///
  /// In en, this message translates to:
  /// **'Bill Number'**
  String get billNumber;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @shareViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp'**
  String get shareViaWhatsApp;

  /// No description provided for @couldNotOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp. Please make sure WhatsApp is installed.'**
  String get couldNotOpenWhatsApp;

  /// No description provided for @chooseHowToShare.
  ///
  /// In en, this message translates to:
  /// **'Choose how to share:'**
  String get chooseHowToShare;

  /// No description provided for @withPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'With Phone Number'**
  String get withPhoneNumber;

  /// No description provided for @withoutPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Without Phone Number'**
  String get withoutPhoneNumber;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get incomeLabel;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get expenseLabel;

  /// No description provided for @transferLabel.
  ///
  /// In en, this message translates to:
  /// **'TRANSFER'**
  String get transferLabel;

  /// No description provided for @accountStatement.
  ///
  /// In en, this message translates to:
  /// **'Account Statement'**
  String get accountStatement;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @exportPDF.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPDF;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @pleaseSelectAccountAndDateRange.
  ///
  /// In en, this message translates to:
  /// **'Please select account and date range'**
  String get pleaseSelectAccountAndDateRange;

  /// No description provided for @pdfExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PDF exported successfully'**
  String get pdfExportedSuccessfully;

  /// No description provided for @errorExportingPDF.
  ///
  /// In en, this message translates to:
  /// **'Error exporting PDF: {error}'**
  String errorExportingPDF(String error);

  /// No description provided for @excelExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Excel exported successfully'**
  String get excelExportedSuccessfully;

  /// No description provided for @errorExportingExcel.
  ///
  /// In en, this message translates to:
  /// **'Error exporting Excel: {error}'**
  String errorExportingExcel(String error);

  /// No description provided for @accountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get accountBalance;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @selectAccountToViewStatement.
  ///
  /// In en, this message translates to:
  /// **'Select an account to view statement'**
  String get selectAccountToViewStatement;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @forSelectedDateRange.
  ///
  /// In en, this message translates to:
  /// **'for the selected date range'**
  String get forSelectedDateRange;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get newAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @pleaseEnterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter account name'**
  String get pleaseEnterAccountName;

  /// No description provided for @accountNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Account Number (Optional)'**
  String get accountNumberOptional;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get noteOptional;

  /// No description provided for @saveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save Account'**
  String get saveAccount;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreated;

  /// No description provided for @accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get accountUpdated;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @noAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found'**
  String get noAccountsFound;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{accountName}\"?'**
  String deleteAccountConfirmation(String accountName);

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @newContact.
  ///
  /// In en, this message translates to:
  /// **'New Contact'**
  String get newContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseEnterName;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (Optional)'**
  String get phoneOptional;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get emailOptional;

  /// No description provided for @importFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Import from Device'**
  String get importFromDevice;

  /// No description provided for @saveContact.
  ///
  /// In en, this message translates to:
  /// **'Save Contact'**
  String get saveContact;

  /// No description provided for @contactCreated.
  ///
  /// In en, this message translates to:
  /// **'Contact created'**
  String get contactCreated;

  /// No description provided for @contactUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contact updated'**
  String get contactUpdated;

  /// No description provided for @contactPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Contact permission is required to import contacts'**
  String get contactPermissionRequired;

  /// No description provided for @noContactsFoundOnDevice.
  ///
  /// In en, this message translates to:
  /// **'No contacts found on device'**
  String get noContactsFoundOnDevice;

  /// No description provided for @selectContact.
  ///
  /// In en, this message translates to:
  /// **'Select Contact'**
  String get selectContact;

  /// No description provided for @errorImportingContact.
  ///
  /// In en, this message translates to:
  /// **'Error importing contact: {error}'**
  String errorImportingContact(String error);

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContact;

  /// No description provided for @deleteContactConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{contactName}\"?'**
  String deleteContactConfirmation(String contactName);

  /// No description provided for @contactDeleted.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted'**
  String get contactDeleted;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @expenseAccountNote.
  ///
  /// In en, this message translates to:
  /// **'The selected account will be debited for the expense'**
  String get expenseAccountNote;

  /// No description provided for @expenseContactNote.
  ///
  /// In en, this message translates to:
  /// **'To which contact you paid the expense. If not, select None'**
  String get expenseContactNote;

  /// No description provided for @pleaseSelectAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get pleaseSelectAnAccount;

  /// No description provided for @billNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Bill Number (Optional)'**
  String get billNumberOptional;

  /// No description provided for @companyNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Company Name (Optional)'**
  String get companyNameOptional;

  /// No description provided for @remarkOptional.
  ///
  /// In en, this message translates to:
  /// **'Remark (Optional)'**
  String get remarkOptional;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @expenseUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get expenseUpdatedSuccessfully;

  /// No description provided for @expenseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenseAddedSuccessfully;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @editIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncome;

  /// No description provided for @incomeAccountNote.
  ///
  /// In en, this message translates to:
  /// **'The selected account will receive the income'**
  String get incomeAccountNote;

  /// No description provided for @incomeContactNote.
  ///
  /// In en, this message translates to:
  /// **'From which contact you received income. If not, select None'**
  String get incomeContactNote;

  /// No description provided for @updateIncome.
  ///
  /// In en, this message translates to:
  /// **'Update Income'**
  String get updateIncome;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save Income'**
  String get saveIncome;

  /// No description provided for @incomeUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Income updated successfully'**
  String get incomeUpdatedSuccessfully;

  /// No description provided for @incomeAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Income added successfully'**
  String get incomeAddedSuccessfully;

  /// No description provided for @editTransfer.
  ///
  /// In en, this message translates to:
  /// **'Edit Transfer'**
  String get editTransfer;

  /// No description provided for @pleaseSelectBothAccounts.
  ///
  /// In en, this message translates to:
  /// **'Please select both accounts'**
  String get pleaseSelectBothAccounts;

  /// No description provided for @fromAndToAccountsMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'From and To accounts must be different'**
  String get fromAndToAccountsMustBeDifferent;

  /// No description provided for @pleaseSelectFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select from account'**
  String get pleaseSelectFromAccount;

  /// No description provided for @pleaseSelectToAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select to account'**
  String get pleaseSelectToAccount;

  /// No description provided for @updateTransfer.
  ///
  /// In en, this message translates to:
  /// **'Update Transfer'**
  String get updateTransfer;

  /// No description provided for @completeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Complete Transfer'**
  String get completeTransfer;

  /// No description provided for @transferUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transfer updated successfully'**
  String get transferUpdatedSuccessfully;

  /// No description provided for @transferCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully'**
  String get transferCompletedSuccessfully;

  /// No description provided for @withPhoneNumberDescription.
  ///
  /// In en, this message translates to:
  /// **'• With phone number: Opens chat directly (if number is on WhatsApp)'**
  String get withPhoneNumberDescription;

  /// No description provided for @withoutPhoneNumberDescription.
  ///
  /// In en, this message translates to:
  /// **'• Without phone number: Opens WhatsApp, you can select the contact'**
  String get withoutPhoneNumberDescription;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @allContacts.
  ///
  /// In en, this message translates to:
  /// **'All Contacts'**
  String get allContacts;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @transactionReport.
  ///
  /// In en, this message translates to:
  /// **'Transaction Report'**
  String get transactionReport;

  /// No description provided for @hideCalendar.
  ///
  /// In en, this message translates to:
  /// **'Hide Calendar'**
  String get hideCalendar;

  /// No description provided for @showCalendar.
  ///
  /// In en, this message translates to:
  /// **'Show Calendar'**
  String get showCalendar;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @noTransactionsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No transactions on {date}'**
  String noTransactionsOnDate(String date);

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transaction'**
  String transactionCount(int count);

  /// No description provided for @transactionCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionCountPlural(int count);

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'Net: ₹{amount}'**
  String netLabel(String amount);

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @whatsAppNotRegisteredMessage.
  ///
  /// In en, this message translates to:
  /// **'If WhatsApp says the number isn\'t registered, try sharing without phone number option.'**
  String get whatsAppNotRegisteredMessage;

  /// No description provided for @receipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receipts;

  /// No description provided for @addReceipt.
  ///
  /// In en, this message translates to:
  /// **'Add Receipt'**
  String get addReceipt;

  /// No description provided for @noReceiptsAdded.
  ///
  /// In en, this message translates to:
  /// **'No receipts added'**
  String get noReceiptsAdded;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @pickPDFFile.
  ///
  /// In en, this message translates to:
  /// **'Pick PDF File'**
  String get pickPDFFile;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @errorPickingPDF.
  ///
  /// In en, this message translates to:
  /// **'Error picking PDF: {error}'**
  String errorPickingPDF(String error);

  /// No description provided for @previewReceipt.
  ///
  /// In en, this message translates to:
  /// **'Preview Receipt'**
  String get previewReceipt;

  /// No description provided for @removeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Remove Receipt'**
  String get removeReceipt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
