// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'खाता वाही';

  @override
  String get home => 'होम';

  @override
  String get reports => 'रिपोर्ट्स';

  @override
  String get accounts => 'खाते';

  @override
  String get contacts => 'संपर्क';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get currentBalance => 'वर्तमान शेष';

  @override
  String get income => 'आय';

  @override
  String get expense => 'व्यय';

  @override
  String get transfer => 'स्थानांतरण';

  @override
  String get allAccounts => 'सभी खाते';

  @override
  String get noTransactionsYet => 'अभी तक कोई लेनदेन नहीं';

  @override
  String get addYourFirstTransaction => 'अपना पहला लेनदेन जोड़ें';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get deleteTransaction => 'लेनदेन हटाएं';

  @override
  String deleteTransactionConfirmation(String type, String amount) {
    return 'क्या आप वाकई इस $type लेनदेन को ₹$amount हटाना चाहते हैं?';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get transactionDeletedSuccessfully =>
      'लेनदेन सफलतापूर्वक हटा दिया गया';

  @override
  String errorDeletingTransaction(String error) {
    return 'लेनदेन हटाने में त्रुटि: $error';
  }

  @override
  String get edit => 'संपादित करें';

  @override
  String get date => 'तारीख';

  @override
  String get account => 'खाता';

  @override
  String get fromAccount => 'से खाता';

  @override
  String get toAccount => 'को खाता';

  @override
  String get contact => 'संपर्क';

  @override
  String get billNumber => 'बिल नंबर';

  @override
  String get company => 'कंपनी';

  @override
  String get remark => 'टिप्पणी';

  @override
  String get shareViaWhatsApp => 'WhatsApp के माध्यम से साझा करें';

  @override
  String get couldNotOpenWhatsApp =>
      'WhatsApp खोल नहीं सके। कृपया सुनिश्चित करें कि WhatsApp स्थापित है।';

  @override
  String get chooseHowToShare => 'चुनें कि कैसे साझा करें:';

  @override
  String get withPhoneNumber => 'फोन नंबर के साथ';

  @override
  String get withoutPhoneNumber => 'बिना फोन नंबर के';

  @override
  String get phone => 'फोन';

  @override
  String get theme => 'थीम';

  @override
  String get systemTheme => 'सिस्टम थीम';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेजी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get gujarati => 'गुजराती';

  @override
  String get incomeLabel => 'आय';

  @override
  String get expenseLabel => 'व्यय';

  @override
  String get transferLabel => 'स्थानांतरण';

  @override
  String get accountStatement => 'खाता विवरण';

  @override
  String get selectAccount => 'खाता चुनें';

  @override
  String get startDate => 'प्रारंभ तिथि';

  @override
  String get endDate => 'समाप्ति तिथि';

  @override
  String get selectDate => 'तारीख चुनें';

  @override
  String get exportPDF => 'PDF निर्यात करें';

  @override
  String get exportExcel => 'Excel निर्यात करें';

  @override
  String get pleaseSelectAccountAndDateRange => 'कृपया खाता और तिथि सीमा चुनें';

  @override
  String get pdfExportedSuccessfully => 'PDF सफलतापूर्वक निर्यात किया गया';

  @override
  String errorExportingPDF(String error) {
    return 'PDF निर्यात करने में त्रुटि: $error';
  }

  @override
  String get excelExportedSuccessfully => 'Excel सफलतापूर्वक निर्यात किया गया';

  @override
  String errorExportingExcel(String error) {
    return 'Excel निर्यात करने में त्रुटि: $error';
  }

  @override
  String get accountBalance => 'खाता शेष';

  @override
  String get net => 'शुद्ध';

  @override
  String get selectAccountToViewStatement => 'विवरण देखने के लिए खाता चुनें';

  @override
  String get noTransactionsFound => 'कोई लेनदेन नहीं मिला';

  @override
  String get forSelectedDateRange => 'चयनित तिथि सीमा के लिए';

  @override
  String get newAccount => 'नया खाता';

  @override
  String get editAccount => 'खाता संपादित करें';

  @override
  String get accountName => 'खाता नाम';

  @override
  String get pleaseEnterAccountName => 'कृपया खाता नाम दर्ज करें';

  @override
  String get accountNumberOptional => 'खाता संख्या (वैकल्पिक)';

  @override
  String get noteOptional => 'नोट (वैकल्पिक)';

  @override
  String get saveAccount => 'खाता सहेजें';

  @override
  String get accountCreated => 'खाता बनाया गया';

  @override
  String get accountUpdated => 'खाता अपडेट किया गया';

  @override
  String error(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get noAccountsFound => 'कोई खाता नहीं मिला';

  @override
  String get addAccount => 'खाता जोड़ें';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String deleteAccountConfirmation(String accountName) {
    return 'क्या आप वाकई \"$accountName\" हटाना चाहते हैं?';
  }

  @override
  String get accountDeleted => 'खाता हटा दिया गया';

  @override
  String get newContact => 'नया संपर्क';

  @override
  String get editContact => 'संपर्क संपादित करें';

  @override
  String get name => 'नाम';

  @override
  String get pleaseEnterName => 'कृपया नाम दर्ज करें';

  @override
  String get phoneOptional => 'फोन (वैकल्पिक)';

  @override
  String get emailOptional => 'ईमेल (वैकल्पिक)';

  @override
  String get importFromDevice => 'डिवाइस से आयात करें';

  @override
  String get saveContact => 'संपर्क सहेजें';

  @override
  String get contactCreated => 'संपर्क बनाया गया';

  @override
  String get contactUpdated => 'संपर्क अपडेट किया गया';

  @override
  String get contactPermissionRequired =>
      'संपर्क आयात करने के लिए संपर्क अनुमति आवश्यक है';

  @override
  String get noContactsFoundOnDevice => 'डिवाइस पर कोई संपर्क नहीं मिला';

  @override
  String get selectContact => 'संपर्क चुनें';

  @override
  String errorImportingContact(String error) {
    return 'संपर्क आयात करने में त्रुटि: $error';
  }

  @override
  String get noContactsFound => 'कोई संपर्क नहीं मिला';

  @override
  String get addContact => 'संपर्क जोड़ें';

  @override
  String get deleteContact => 'संपर्क हटाएं';

  @override
  String deleteContactConfirmation(String contactName) {
    return 'क्या आप वाकई \"$contactName\" हटाना चाहते हैं?';
  }

  @override
  String get contactDeleted => 'संपर्क हटा दिया गया';

  @override
  String get amount => 'राशि';

  @override
  String get addExpense => 'व्यय जोड़ें';

  @override
  String get editExpense => 'व्यय संपादित करें';

  @override
  String get expenseAccountNote => 'चयनित खाते से व्यय का खर्च किया जाएगा';

  @override
  String get expenseContactNote =>
      'आपने किस संपर्क को व्यय का भुगतान किया। यदि नहीं, तो कोई नहीं चुनें';

  @override
  String get pleaseSelectAnAccount => 'कृपया खाता चुनें';

  @override
  String get billNumberOptional => 'बिल नंबर (वैकल्पिक)';

  @override
  String get companyNameOptional => 'कंपनी नाम (वैकल्पिक)';

  @override
  String get remarkOptional => 'टिप्पणी (वैकल्पिक)';

  @override
  String get updateExpense => 'व्यय अपडेट करें';

  @override
  String get saveExpense => 'व्यय सहेजें';

  @override
  String get expenseUpdatedSuccessfully => 'व्यय सफलतापूर्वक अपडेट किया गया';

  @override
  String get expenseAddedSuccessfully => 'व्यय सफलतापूर्वक जोड़ा गया';

  @override
  String get addIncome => 'आय जोड़ें';

  @override
  String get editIncome => 'आय संपादित करें';

  @override
  String get incomeAccountNote => 'चयनित खाते में आय प्राप्त होगी';

  @override
  String get incomeContactNote =>
      'आपको किस संपर्क से आय प्राप्त हुई। यदि नहीं, तो कोई नहीं चुनें';

  @override
  String get updateIncome => 'आय अपडेट करें';

  @override
  String get saveIncome => 'आय सहेजें';

  @override
  String get incomeUpdatedSuccessfully => 'आय सफलतापूर्वक अपडेट की गई';

  @override
  String get incomeAddedSuccessfully => 'आय सफलतापूर्वक जोड़ी गई';

  @override
  String get editTransfer => 'स्थानांतरण संपादित करें';

  @override
  String get pleaseSelectBothAccounts => 'कृपया दोनों खाते चुनें';

  @override
  String get fromAndToAccountsMustBeDifferent => 'से और को खाते अलग होने चाहिए';

  @override
  String get pleaseSelectFromAccount => 'कृपया से खाता चुनें';

  @override
  String get pleaseSelectToAccount => 'कृपया को खाता चुनें';

  @override
  String get updateTransfer => 'स्थानांतरण अपडेट करें';

  @override
  String get completeTransfer => 'स्थानांतरण पूरा करें';

  @override
  String get transferUpdatedSuccessfully =>
      'स्थानांतरण सफलतापूर्वक अपडेट किया गया';

  @override
  String get transferCompletedSuccessfully =>
      'स्थानांतरण सफलतापूर्वक पूरा किया गया';

  @override
  String get withPhoneNumberDescription =>
      '• फोन नंबर के साथ: सीधे चैट खोलता है (यदि नंबर WhatsApp पर है)';

  @override
  String get withoutPhoneNumberDescription =>
      '• बिना फोन नंबर के: WhatsApp खोलता है, आप संपर्क चुन सकते हैं';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get timeline => 'टाइमलाइन';

  @override
  String get calendar => 'कैलेंडर';

  @override
  String get allContacts => 'सभी संपर्क';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get allTime => 'सभी समय';

  @override
  String get transactionReport => 'लेनदेन रिपोर्ट';

  @override
  String get hideCalendar => 'कैलेंडर छुपाएं';

  @override
  String get showCalendar => 'कैलेंडर दिखाएं';

  @override
  String get noTransactions => 'कोई लेनदेन नहीं';

  @override
  String noTransactionsOnDate(String date) {
    return '$date को कोई लेनदेन नहीं';
  }

  @override
  String transactionCount(int count) {
    return '$count लेनदेन';
  }

  @override
  String transactionCountPlural(int count) {
    return '$count लेनदेन';
  }

  @override
  String netLabel(String amount) {
    return 'शुद्ध: ₹$amount';
  }

  @override
  String get transactionDetails => 'लेनदेन विवरण';

  @override
  String get editTransaction => 'लेनदेन संपादित करें';

  @override
  String get whatsAppNotRegisteredMessage =>
      'यदि WhatsApp कहता है कि नंबर पंजीकृत नहीं है, तो बिना फोन नंबर विकल्प के साझा करने का प्रयास करें।';

  @override
  String get receipts => 'रसीदें';

  @override
  String get addReceipt => 'रसीद जोड़ें';

  @override
  String get noReceiptsAdded => 'कोई रसीद नहीं जोड़ी गई';

  @override
  String get pickFromGallery => 'गैलरी से चुनें';

  @override
  String get takePhoto => 'फोटो लें';

  @override
  String get pickPDFFile => 'PDF फ़ाइल चुनें';

  @override
  String errorPickingImage(String error) {
    return 'छवि चुनने में त्रुटि: $error';
  }

  @override
  String errorPickingPDF(String error) {
    return 'PDF चुनने में त्रुटि: $error';
  }

  @override
  String get previewReceipt => 'रसीद पूर्वावलोकन';

  @override
  String get removeReceipt => 'रसीद हटाएं';
}
