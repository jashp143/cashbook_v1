// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'ખાતા વાહી';

  @override
  String get home => 'હોમ';

  @override
  String get reports => 'રિપોર્ટ્સ';

  @override
  String get accounts => 'ખાતાઓ';

  @override
  String get contacts => 'સંપર્કો';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get currentBalance => 'વર્તમાન શેષ';

  @override
  String get income => 'આવક';

  @override
  String get expense => 'ખર્ચ';

  @override
  String get transfer => 'સ્થાનાંતરણ';

  @override
  String get allAccounts => 'બધા ખાતાઓ';

  @override
  String get noTransactionsYet => 'હજુ સુધી કોઈ વ્યવહાર નથી';

  @override
  String get addYourFirstTransaction => 'તમારો પહેલો વ્યવહાર ઉમેરો';

  @override
  String get today => 'આજે';

  @override
  String get yesterday => 'ગઈકાલે';

  @override
  String get deleteTransaction => 'વ્યવહાર કાઢી નાખો';

  @override
  String deleteTransactionConfirmation(String type, String amount) {
    return 'શું તમે ખરેખર આ $type વ્યવહાર ₹$amount કાઢી નાખવા માંગો છો?';
  }

  @override
  String get cancel => 'રદ કરો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get transactionDeletedSuccessfully =>
      'વ્યવહાર સફળતાપૂર્વક કાઢી નાખ્યો';

  @override
  String errorDeletingTransaction(String error) {
    return 'વ્યવહાર કાઢવામાં ભૂલ: $error';
  }

  @override
  String get edit => 'સંપાદિત કરો';

  @override
  String get date => 'તારીખ';

  @override
  String get account => 'ખાતું';

  @override
  String get fromAccount => 'ખાતા માંથી';

  @override
  String get toAccount => 'ખાતા માં';

  @override
  String get contact => 'સંપર્ક';

  @override
  String get billNumber => 'બિલ નંબર';

  @override
  String get company => 'કંપની';

  @override
  String get remark => 'ટિપ્પણી';

  @override
  String get shareViaWhatsApp => 'WhatsApp દ્વારા શેર કરો';

  @override
  String get couldNotOpenWhatsApp =>
      'WhatsApp ખોલી શક્યા નહીં. કૃપા કરીને ખાતરી કરો કે WhatsApp ઇન્સ્ટોલ થયેલ છે.';

  @override
  String get chooseHowToShare => 'કેવી રીતે શેર કરવું તે પસંદ કરો:';

  @override
  String get withPhoneNumber => 'ફોન નંબર સાથે';

  @override
  String get withoutPhoneNumber => 'ફોન નંબર વગર';

  @override
  String get phone => 'ફોન';

  @override
  String get theme => 'થીમ';

  @override
  String get systemTheme => 'સિસ્ટમ થીમ';

  @override
  String get lightMode => 'લાઇટ મોડ';

  @override
  String get darkMode => 'ડાર્ક મોડ';

  @override
  String get language => 'ભાષા';

  @override
  String get english => 'અંગ્રેજી';

  @override
  String get hindi => 'હિંદી';

  @override
  String get gujarati => 'ગુજરાતી';

  @override
  String get incomeLabel => 'આવક';

  @override
  String get expenseLabel => 'ખર્ચ';

  @override
  String get transferLabel => 'સ્થાનાંતરણ';

  @override
  String get accountStatement => 'ખાતા વિગત';

  @override
  String get selectAccount => 'ખાતું પસંદ કરો';

  @override
  String get startDate => 'પ્રારંભ તારીખ';

  @override
  String get endDate => 'સમાપ્તિ તારીખ';

  @override
  String get selectDate => 'તારીખ પસંદ કરો';

  @override
  String get exportPDF => 'PDF નિકાસ કરો';

  @override
  String get exportExcel => 'Excel નિકાસ કરો';

  @override
  String get pleaseSelectAccountAndDateRange =>
      'કૃપા કરીને ખાતું અને તારીખ શ્રેણી પસંદ કરો';

  @override
  String get pdfExportedSuccessfully => 'PDF સફળતાપૂર્વક નિકાસ થયો';

  @override
  String errorExportingPDF(String error) {
    return 'PDF નિકાસ કરવામાં ભૂલ: $error';
  }

  @override
  String get excelExportedSuccessfully => 'Excel સફળતાપૂર્વક નિકાસ થયો';

  @override
  String errorExportingExcel(String error) {
    return 'Excel નિકાસ કરવામાં ભૂલ: $error';
  }

  @override
  String get accountBalance => 'ખાતું શેષ';

  @override
  String get net => 'શુદ્ધ';

  @override
  String get selectAccountToViewStatement => 'વિગત જોવા માટે ખાતું પસંદ કરો';

  @override
  String get noTransactionsFound => 'કોઈ વ્યવહાર મળ્યો નથી';

  @override
  String get forSelectedDateRange => 'પસંદ કરેલી તારીખ શ્રેણી માટે';

  @override
  String get newAccount => 'નવું ખાતું';

  @override
  String get editAccount => 'ખાતું સંપાદિત કરો';

  @override
  String get accountName => 'ખાતું નામ';

  @override
  String get pleaseEnterAccountName => 'કૃપા કરીને ખાતું નામ દાખલ કરો';

  @override
  String get accountNumberOptional => 'ખાતું નંબર (વૈકલ્પિક)';

  @override
  String get noteOptional => 'નોંધ (વૈકલ્પિક)';

  @override
  String get saveAccount => 'ખાતું સાચવો';

  @override
  String get accountCreated => 'ખાતું બનાવ્યું';

  @override
  String get accountUpdated => 'ખાતું અપડેટ થયું';

  @override
  String error(String error) {
    return 'ભૂલ: $error';
  }

  @override
  String get noAccountsFound => 'કોઈ ખાતું મળ્યું નથી';

  @override
  String get addAccount => 'ખાતું ઉમેરો';

  @override
  String get deleteAccount => 'ખાતું કાઢી નાખો';

  @override
  String deleteAccountConfirmation(String accountName) {
    return 'શું તમે ખરેખર \"$accountName\" કાઢી નાખવા માંગો છો?';
  }

  @override
  String get accountDeleted => 'ખાતું કાઢી નાખ્યું';

  @override
  String get newContact => 'નવો સંપર્ક';

  @override
  String get editContact => 'સંપર્ક સંપાદિત કરો';

  @override
  String get name => 'નામ';

  @override
  String get pleaseEnterName => 'કૃપા કરીને નામ દાખલ કરો';

  @override
  String get phoneOptional => 'ફોન (વૈકલ્પિક)';

  @override
  String get emailOptional => 'ઇમેઇલ (વૈકલ્પિક)';

  @override
  String get importFromDevice => 'ડિવાઇસમાંથી આયાત કરો';

  @override
  String get saveContact => 'સંપર્ક સાચવો';

  @override
  String get contactCreated => 'સંપર્ક બનાવ્યો';

  @override
  String get contactUpdated => 'સંપર્ક અપડેટ થયો';

  @override
  String get contactPermissionRequired =>
      'સંપર્ક આયાત કરવા માટે સંપર્ક પરવાનગી જરૂરી છે';

  @override
  String get noContactsFoundOnDevice => 'ડિવાઇસ પર કોઈ સંપર્ક મળ્યો નથી';

  @override
  String get selectContact => 'સંપર્ક પસંદ કરો';

  @override
  String errorImportingContact(String error) {
    return 'સંપર્ક આયાત કરવામાં ભૂલ: $error';
  }

  @override
  String get noContactsFound => 'કોઈ સંપર્ક મળ્યો નથી';

  @override
  String get addContact => 'સંપર્ક ઉમેરો';

  @override
  String get deleteContact => 'સંપર્ક કાઢી નાખો';

  @override
  String deleteContactConfirmation(String contactName) {
    return 'શું તમે ખરેખર \"$contactName\" કાઢી નાખવા માંગો છો?';
  }

  @override
  String get contactDeleted => 'સંપર્ક કાઢી નાખ્યો';

  @override
  String get amount => 'રકમ';

  @override
  String get addExpense => 'ખર્ચ ઉમેરો';

  @override
  String get editExpense => 'ખર્ચ સંપાદિત કરો';

  @override
  String get expenseAccountNote => 'પસંદ કરેલ ખાતામાંથી ખર્ચ ડેબિટ થશે';

  @override
  String get expenseContactNote =>
      'તમે કયા સંપર્કને ખર્ચનો ભુગતાન કર્યો. જો નહીં, તો કંઈ નહીં પસંદ કરો';

  @override
  String get pleaseSelectAnAccount => 'કૃપા કરીને ખાતું પસંદ કરો';

  @override
  String get billNumberOptional => 'બિલ નંબર (વૈકલ્પિક)';

  @override
  String get companyNameOptional => 'કંપની નામ (વૈકલ્પિક)';

  @override
  String get remarkOptional => 'ટિપ્પણી (વૈકલ્પિક)';

  @override
  String get updateExpense => 'ખર્ચ અપડેટ કરો';

  @override
  String get saveExpense => 'ખર્ચ સાચવો';

  @override
  String get expenseUpdatedSuccessfully => 'ખર્ચ સફળતાપૂર્વક અપડેટ થયો';

  @override
  String get expenseAddedSuccessfully => 'ખર્ચ સફળતાપૂર્વક ઉમેર્યો';

  @override
  String get addIncome => 'આવક ઉમેરો';

  @override
  String get editIncome => 'આવક સંપાદિત કરો';

  @override
  String get incomeAccountNote => 'પસંદ કરેલ ખાતામાં આવક પ્રાપ્ત થશે';

  @override
  String get incomeContactNote =>
      'તમને કયા સંપર્ક પાસેથી આવક પ્રાપ્ત થઈ. જો નહીં, તો કંઈ નહીં પસંદ કરો';

  @override
  String get updateIncome => 'આવક અપડેટ કરો';

  @override
  String get saveIncome => 'આવક સાચવો';

  @override
  String get incomeUpdatedSuccessfully => 'આવક સફળતાપૂર્વક અપડેટ થઈ';

  @override
  String get incomeAddedSuccessfully => 'આવક સફળતાપૂર્વક ઉમેરી';

  @override
  String get editTransfer => 'સ્થાનાંતરણ સંપાદિત કરો';

  @override
  String get pleaseSelectBothAccounts => 'કૃપા કરીને બંને ખાતાઓ પસંદ કરો';

  @override
  String get fromAndToAccountsMustBeDifferent =>
      'માંથી અને માં ખાતાઓ અલગ હોવા જોઈએ';

  @override
  String get pleaseSelectFromAccount => 'કૃપા કરીને માંથી ખાતું પસંદ કરો';

  @override
  String get pleaseSelectToAccount => 'કૃપા કરીને માં ખાતું પસંદ કરો';

  @override
  String get updateTransfer => 'સ્થાનાંતરણ અપડેટ કરો';

  @override
  String get completeTransfer => 'સ્થાનાંતરણ પૂર્ણ કરો';

  @override
  String get transferUpdatedSuccessfully => 'સ્થાનાંતરણ સફળતાપૂર્વક અપડેટ થયું';

  @override
  String get transferCompletedSuccessfully =>
      'સ્થાનાંતરણ સફળતાપૂર્વક પૂર્ણ થયું';

  @override
  String get withPhoneNumberDescription =>
      '• ફોન નંબર સાથે: સીધા ચેટ ખોલે છે (જો નંબર WhatsApp પર હોય)';

  @override
  String get withoutPhoneNumberDescription =>
      '• ફોન નંબર વગર: WhatsApp ખોલે છે, તમે સંપર્ક પસંદ કરી શકો છો';

  @override
  String get filters => 'ફિલ્ટર્સ';

  @override
  String get timeline => 'ટાઇમલાઇન';

  @override
  String get calendar => 'કેલેન્ડર';

  @override
  String get allContacts => 'બધા સંપર્કો';

  @override
  String get thisWeek => 'આ સપ્તાહ';

  @override
  String get thisMonth => 'આ મહિનો';

  @override
  String get allTime => 'બધો સમય';

  @override
  String get transactionReport => 'વ્યવહાર રિપોર્ટ';

  @override
  String get hideCalendar => 'કેલેન્ડર છુપાવો';

  @override
  String get showCalendar => 'કેલેન્ડર બતાવો';

  @override
  String get noTransactions => 'કોઈ વ્યવહાર નથી';

  @override
  String noTransactionsOnDate(String date) {
    return '$date પર કોઈ વ્યવહાર નથી';
  }

  @override
  String transactionCount(int count) {
    return '$count વ્યવહાર';
  }

  @override
  String transactionCountPlural(int count) {
    return '$count વ્યવહારો';
  }

  @override
  String netLabel(String amount) {
    return 'શુદ્ધ: ₹$amount';
  }

  @override
  String get transactionDetails => 'વ્યવહાર વિગતો';

  @override
  String get editTransaction => 'વ્યવહાર સંપાદિત કરો';

  @override
  String get whatsAppNotRegisteredMessage =>
      'જો WhatsApp કહે છે કે નંબર નોંધાયેલ નથી, તો ફોન નંબર વિના વિકલ્પ વગર શેર કરવાનો પ્રયાસ કરો.';

  @override
  String get receipts => 'રસીદો';

  @override
  String get addReceipt => 'રસીદ ઉમેરો';

  @override
  String get noReceiptsAdded => 'કોઈ રસીદ ઉમેરાયી નથી';

  @override
  String get pickFromGallery => 'ગેલેરીમાંથી પસંદ કરો';

  @override
  String get takePhoto => 'ફોટો લો';

  @override
  String get pickPDFFile => 'PDF ફાઇલ પસંદ કરો';

  @override
  String errorPickingImage(String error) {
    return 'છબી પસંદ કરવામાં ભૂલ: $error';
  }

  @override
  String errorPickingPDF(String error) {
    return 'PDF પસંદ કરવામાં ભૂલ: $error';
  }

  @override
  String get previewReceipt => 'રસીદ પૂર્વાવલોકન';

  @override
  String get removeReceipt => 'રસીદ કાઢી નાખો';
}
