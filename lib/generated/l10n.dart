// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `MoneyMove`
  String get appTitle {
    return Intl.message('MoneyMove', name: 'appTitle', desc: '', args: []);
  }

  /// `No description`
  String get noDescription {
    return Intl.message(
      'No description',
      name: 'noDescription',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get editText {
    return Intl.message('Edit', name: 'editText', desc: '', args: []);
  }

  /// `Delete`
  String get deleteText {
    return Intl.message('Delete', name: 'deleteText', desc: '', args: []);
  }

  /// `Home`
  String get navigationTextHome {
    return Intl.message('Home', name: 'navigationTextHome', desc: '', args: []);
  }

  /// `Transactions`
  String get navigationTextTransactions {
    return Intl.message(
      'Transactions',
      name: 'navigationTextTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Debts`
  String get navigationTextDeudas {
    return Intl.message(
      'Debts',
      name: 'navigationTextDeudas',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get titleTransactionsScreen {
    return Intl.message(
      'Transactions',
      name: 'titleTransactionsScreen',
      desc: '',
      args: [],
    );
  }

  /// `No transactions yet 😴`
  String get noTransactionsYet {
    return Intl.message(
      'No transactions yet 😴',
      name: 'noTransactionsYet',
      desc: '',
      args: [],
    );
  }

  /// `Add Transaction`
  String get addTransaction {
    return Intl.message(
      'Add Transaction',
      name: 'addTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Choose category for your transaction`
  String get chooseCategoryManualTitle {
    return Intl.message(
      'Choose category for your transaction',
      name: 'chooseCategoryManualTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Transaction`
  String get editTransaccionText {
    return Intl.message(
      'Edit Transaction',
      name: 'editTransaccionText',
      desc: '',
      args: [],
    );
  }

  /// `Transaction deleted`
  String get deletedTransactionMessage {
    return Intl.message(
      'Transaction deleted',
      name: 'deletedTransactionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Debts`
  String get titleDeudasScreen {
    return Intl.message('Debts', name: 'titleDeudasScreen', desc: '', args: []);
  }

  /// `No debts yet 😴`
  String get noDeudasYet {
    return Intl.message(
      'No debts yet 😴',
      name: 'noDeudasYet',
      desc: '',
      args: [],
    );
  }

  /// `Add Debt`
  String get addDeuda {
    return Intl.message('Add Debt', name: 'addDeuda', desc: '', args: []);
  }

  /// `Edit Debt`
  String get editDeudaText {
    return Intl.message('Edit Debt', name: 'editDeudaText', desc: '', args: []);
  }

  /// `Language changed`
  String get changeLanguage {
    return Intl.message(
      'Language changed',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `See all transactions`
  String get SeeAllTransactions {
    return Intl.message(
      'See all transactions',
      name: 'SeeAllTransactions',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'Texto random' key
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
