import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MoneyMove'**
  String get appTitle;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @editText.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editText;

  /// No description provided for @cancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelText;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteText;

  /// No description provided for @navigationTextHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationTextHome;

  /// No description provided for @navigationTextTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navigationTextTransactions;

  /// No description provided for @navigationTextDeudas.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get navigationTextDeudas;

  /// No description provided for @titleText.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleText;

  /// No description provided for @dateText.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateText;

  /// No description provided for @descriptionText.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionText;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @cat_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get cat_food;

  /// No description provided for @cat_transport.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get cat_transport;

  /// No description provided for @cat_leisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get cat_leisure;

  /// No description provided for @cat_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get cat_health;

  /// No description provided for @cat_education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get cat_education;

  /// No description provided for @cat_church.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get cat_church;

  /// No description provided for @cat_job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get cat_job;

  /// No description provided for @cat_pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get cat_pet;

  /// No description provided for @cat_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get cat_home;

  /// No description provided for @cat_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get cat_services;

  /// No description provided for @cat_debt.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get cat_debt;

  /// No description provided for @cat_others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get cat_others;

  /// No description provided for @titleTransactionsScreen.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get titleTransactionsScreen;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet 😴'**
  String get noTransactionsYet;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @chooseCategoryManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose category for your transaction'**
  String get chooseCategoryManualTitle;

  /// No description provided for @editTransaccionText.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaccionText;

  /// No description provided for @accitionNotUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get accitionNotUndone;

  /// No description provided for @deleteTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransactionText;

  /// No description provided for @deletedTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get deletedTransactionMessage;

  /// No description provided for @deletedDeudaMessege.
  ///
  /// In en, this message translates to:
  /// **'Debt deleted'**
  String get deletedDeudaMessege;

  /// No description provided for @titleDeudasScreen.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get titleDeudasScreen;

  /// No description provided for @noDeudasYet.
  ///
  /// In en, this message translates to:
  /// **'No debts yet 😴'**
  String get noDeudasYet;

  /// No description provided for @addDeuda.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDeuda;

  /// No description provided for @editDeudaText.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt'**
  String get editDeudaText;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Idioma cambiado'**
  String get changeLanguage;

  /// No description provided for @seeAllTransactionsText.
  ///
  /// In en, this message translates to:
  /// **'See all transactions'**
  String get seeAllTransactionsText;

  /// No description provided for @seeAllDeudasText.
  ///
  /// In en, this message translates to:
  /// **'See all debts'**
  String get seeAllDeudasText;

  /// No description provided for @transactionNotExist.
  ///
  /// In en, this message translates to:
  /// **'The transaction does not exist'**
  String get transactionNotExist;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetailsTitle;

  /// No description provided for @expenseMade.
  ///
  /// In en, this message translates to:
  /// **'Expense Made'**
  String get expenseMade;

  /// No description provided for @incomeReceived.
  ///
  /// In en, this message translates to:
  /// **'Income Received'**
  String get incomeReceived;

  /// No description provided for @inputTitleTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Transaction Title'**
  String get inputTitleTransactionText;

  /// No description provided for @writeTitleTransactionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter transaction title'**
  String get writeTitleTransactionHint;

  /// No description provided for @descriptionTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Transaction Description'**
  String get descriptionTransactionText;

  /// No description provided for @optionalHintText.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalHintText;

  /// No description provided for @expenseText.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseText;

  /// No description provided for @incomeText.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeText;

  /// No description provided for @amountText.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountText;

  /// No description provided for @analizingText.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analizingText;

  /// No description provided for @selectCategoryText.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryText;

  /// No description provided for @saveTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransactionText;

  /// No description provided for @payableText.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payableText;

  /// No description provided for @receivableText.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivableText;

  /// No description provided for @withInvolucradoText.
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get withInvolucradoText;

  /// No description provided for @venceText.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get venceText;

  /// No description provided for @allAlrightDeudasText.
  ///
  /// In en, this message translates to:
  /// **'All settled 🎉'**
  String get allAlrightDeudasText;

  /// No description provided for @noOutstandingDeudas.
  ///
  /// In en, this message translates to:
  /// **'You have no outstanding debts'**
  String get noOutstandingDeudas;

  /// No description provided for @transactionsWillAppearHereText.
  ///
  /// In en, this message translates to:
  /// **'Your transactions will appear here'**
  String get transactionsWillAppearHereText;

  /// No description provided for @deudaTitleText.
  ///
  /// In en, this message translates to:
  /// **'Debt Title'**
  String get deudaTitleText;

  /// No description provided for @deudaEjTitleText.
  ///
  /// In en, this message translates to:
  /// **'Ex. Shoe purchase'**
  String get deudaEjTitleText;

  /// No description provided for @yoDeboText.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get yoDeboText;

  /// No description provided for @meDebenText.
  ///
  /// In en, this message translates to:
  /// **'They owe me'**
  String get meDebenText;

  /// No description provided for @involucradoNameHint.
  ///
  /// In en, this message translates to:
  /// **'Person\'s name'**
  String get involucradoNameHint;

  /// No description provided for @saveDeudaText.
  ///
  /// In en, this message translates to:
  /// **'Save Debt'**
  String get saveDeudaText;

  /// No description provided for @quienLeDeboText.
  ///
  /// In en, this message translates to:
  /// **'Who do I owe?'**
  String get quienLeDeboText;

  /// No description provided for @quienMeDebeText.
  ///
  /// In en, this message translates to:
  /// **'Who owes me?'**
  String get quienMeDebeText;

  /// No description provided for @totalBalanceText.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalanceText;

  /// No description provided for @incomesText.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomesText;

  /// No description provided for @expencesText.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expencesText;

  /// No description provided for @lastTransactionsText.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get lastTransactionsText;

  /// No description provided for @lastDeudasText.
  ///
  /// In en, this message translates to:
  /// **'Outstanding debts'**
  String get lastDeudasText;

  /// No description provided for @areYouSureTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re sure?'**
  String get areYouSureTitle;

  /// No description provided for @deudasPorPagarText.
  ///
  /// In en, this message translates to:
  /// **'Debts to pay'**
  String get deudasPorPagarText;

  /// No description provided for @deudasPorCobrarText.
  ///
  /// In en, this message translates to:
  /// **'Debts to collect'**
  String get deudasPorCobrarText;

  /// No description provided for @pagadaText.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get pagadaText;

  /// No description provided for @progressText.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressText;

  /// No description provided for @abonadoText.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get abonadoText;

  /// No description provided for @restanteText.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get restanteText;

  /// No description provided for @toText.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get toText;

  /// No description provided for @fromText.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get fromText;

  /// No description provided for @pagar.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get pagar;

  /// No description provided for @abonar.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get abonar;

  /// No description provided for @insertAmountPaymentText.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount to pay'**
  String get insertAmountPaymentText;

  /// No description provided for @abonoForText.
  ///
  /// In en, this message translates to:
  /// **'Credit towards'**
  String get abonoForText;

  /// No description provided for @pagoDeText.
  ///
  /// In en, this message translates to:
  /// **'Payment for'**
  String get pagoDeText;

  /// No description provided for @confirmText.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmText;

  /// No description provided for @markAsPaidText.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid?'**
  String get markAsPaidText;

  /// No description provided for @markAsPaidConfirmText.
  ///
  /// In en, this message translates to:
  /// **'This will pay off the remaining balance.'**
  String get markAsPaidConfirmText;

  /// No description provided for @deudaPaidSucessText.
  ///
  /// In en, this message translates to:
  /// **'Debt paid successfully'**
  String get deudaPaidSucessText;

  /// No description provided for @totalPorPagarText.
  ///
  /// In en, this message translates to:
  /// **'Total to Pay'**
  String get totalPorPagarText;

  /// No description provided for @totalPorCobrarText.
  ///
  /// In en, this message translates to:
  /// **'Total to Collect'**
  String get totalPorCobrarText;

  /// No description provided for @paidDeudasText.
  ///
  /// In en, this message translates to:
  /// **'Paid debts'**
  String get paidDeudasText;

  /// No description provided for @recivedDeudasText.
  ///
  /// In en, this message translates to:
  /// **'Collected debts'**
  String get recivedDeudasText;

  /// No description provided for @abonoSucessText.
  ///
  /// In en, this message translates to:
  /// **'Payment made successfully'**
  String get abonoSucessText;

  /// No description provided for @putAmountHigherZeroText.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get putAmountHigherZeroText;

  /// No description provided for @putAmountLowerText.
  ///
  /// In en, this message translates to:
  /// **'The amount exceeds the remaining balance'**
  String get putAmountLowerText;

  /// No description provided for @errorHasOccurredText.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error has occurred'**
  String get errorHasOccurredText;

  /// No description provided for @seeAsociatedDeuda.
  ///
  /// In en, this message translates to:
  /// **'See associated debt'**
  String get seeAsociatedDeuda;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
