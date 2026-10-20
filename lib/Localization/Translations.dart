import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'language.dart';

class Translations {
  static Future<Translations> load(Locale locale) {
    final String name =
    (locale.countryCode != null && locale.countryCode!.isEmpty)
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _) {
      Intl.defaultLocale = localeName;
      return new Translations();
    });
  }

  static Translations? of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  String get username {
    return Intl.message(
      'Username',
      name: 'username',
    );
  }

  String get not_valid_username {
    return Intl.message(
      'Not Valid Username',
      name: 'not_valid_username',
    );
  }

  String get password {
    return Intl.message(
      'password',
      name: 'password',
    );
  }

  String get password_is_too_short {
    return Intl.message(
      'password is too short',
      name: 'password_is_too_short',
    );
  }

  String get login {
    return Intl.message(
      'Login',
      name: 'login',
    );
  }

  String get language {
    return Intl.message(
      'عربي',
      name: 'language',
    );
  }

  String get links {
    return Intl.message(
      'Links',
      name: 'links',
    );
  }

  String get contacts {
    return Intl.message(
      'Contacts',
      name: 'contacts',
    );
  }

  String get attendance {
    return Intl.message(
      'Attendance',
      name: 'attendance',
    );
  }

  String get support {
    return Intl.message(
      'Support',
      name: 'support',
    );
  }

  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
    );
  }
  String get CompanyNumber_Validation {
    return Intl.message(
      'CompanyNumber_Validation',
      name: 'companyNumber_Validation',
    );
  }
  String get CompanyNumber {
    return Intl.message(
      'CompanyNumber',
      name: 'companyNumber',
    );
  }
  String get Login_btn {
    return Intl.message(
      'Login_btn',
      name: 'login_btn',
    );
  }
  String get ErrorTitle {
    return Intl.message(
      'errorTitle',
      name: 'errorTitle',
    );
  }
  String get ErrorDes {
    return Intl.message(
      'errorDes',
      name: 'errorDes',
    );
  }
  String get CheckInternet {
    return Intl.message(
      'CheckInternet',
      name: 'checkInternet',
    );
  }
  String get Please {
    return Intl.message(
      'Please',
      name: 'please',
    );
  }
  String get LastVersion {
    return Intl.message(
      'LastVersion',
      name: 'lastVersion',
    );
  }
  String get Ok {
    return Intl.message(
      'Ok',
      name: 'ok',
    );
  }  String get success_msg {
    return Intl.message(
      'success_msg',
      name: 'success_msg',
    );
  }String get username_Validation {
    return Intl.message(
      'username_Validation',
      name: 'username_Validation',
    );
  }String get comment_Validation {
    return Intl.message(
      'comment_Validation',
      name: 'comment_Validation',
    );
  }String get Pay_Validation {
    return Intl.message(
      'Pay_Validation',
      name: 'Pay_Validation',
    );
  }String get serviceType_Validation {
    return Intl.message(
      'serviceType_Validation',
      name: 'serviceType_Validation',
    );
  }
  String get Password_Validation {
    return Intl.message(
      'Password_Validation',
      name: 'password_Validation',
    );
  }
  String get Email_Validation {
    return Intl.message(
      'Email_Validation',
      name: 'email_Validation',
    );
  }
  String get Password {
    return Intl.message(
      'Password',
      name: 'password',
    );
  }
  String get Email {
    return Intl.message(
      'Email',
      name: 'email',
    );
  }
  String get Home_page {
    return Intl.message(
      'Home_page',
      name: 'home_page',
    );
  }
  String get Log_out {
    return Intl.message(
      'Log_out',
      name: 'log_out',
    );
  }
  String get Sales {
    return Intl.message(
      'Sales',
      name: 'sales',
    );
  }
  String get Purchases {
    return Intl.message(
      'Purchases',
      name: 'purchases',
    );
  }
  String get Monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
    );
  }
  String get Daily {
    return Intl.message(
      'Daily',
      name: 'daily',
    );
  }
  String get Annual {
    return Intl.message(
      'Annual',
      name: 'annual',
    );
  }
  String get Language_flag {
    return Intl.message(
      'Language_flag',
      name: 'language_flag',
    );
  }
  String get From {
    return Intl.message(
      'From',
      name: 'from',
    );
  }
  String get To {
    return Intl.message(
      'To',
      name: 'to',
    );
  }
  String get NoData {
    return Intl.message(
      'NoData',
      name: 'noData',
    );
  }
  String get Supplier {
    return Intl.message(
      'Supplier',
      name: 'supplier',
    );
  }
  String get Delegate {
    return Intl.message(
      'Delegate',
      name: 'delegate',
    );
  }
    String get Phone_number {
      return Intl.message(
        'Phone_number',
        name: 'phone_number',
      );
    }
  String get Phone_number_Validation {
    return Intl.message(
      'Phone_number_Validation',
      name: 'phone_number_Validation',
    );
  }

  String get Code {
    return Intl.message(
      'Code',
      name: 'code',
    );
  }

  String get Code_Validation {
    return Intl.message(
      'Code_Validation',
      name: 'code_Validation',
    );
  }
  String get Code_resend {
    return Intl.message(
      'Code_resend',
      name: 'code_resend',
    );
  }
  String get New_user {
    return Intl.message(
      'New_user',
      name: 'new_user',
    );
  }

  String get First_name_Validation {
    return Intl.message(
      'First_name_Validation',
      name: 'first_name_Validation',
    );
  }
  String get First_name {
    return Intl.message(
      'First_name',
      name: 'first_name',
    );
  }
  String get Last_name_Validation {
    return Intl.message(
      'Last_name_Validation',
      name: 'last_name_Validation',
    );
  }
  String get Last_name {
    return Intl.message(
      'Last_name',
      name: 'last_name',
    );
  }
  String get Services {
    return Intl.message(
      'Services',
      name: 'services',
    );
  }
  String get Requests {
    return Intl.message(
      'Requests',
      name: 'requests',
    );
  }
  String get Info {
    return Intl.message(
      'Info',
      name: 'info',
    );
  }
  String get Connect_us {
    return Intl.message(
      'Connect_us',
      name: 'connect_us',
    );
  }
  String get About_us {
    return Intl.message(
      'About_us',
      name: 'about_us',
    );
  }
  String get Language {
    return Intl.message(
      'Language',
      name: 'language',
    );
  }
  String get Station_services {
    return Intl.message(
      'Station_services',
      name: 'Station_services',
    );
  }
  String get Station_locations {
    return Intl.message(
      'Station_locations',
      name: 'Station_locations',
    );
  }
  String get Customer_services {
    return Intl.message(
      'Customer_services',
      name: 'Customer_services',
    );
  }
  String get Station_maintenance {
    return Intl.message(
      'Station_maintenance',
      name: 'Station_maintenance',
    );
  }
  String get SAR {
    return Intl.message(
      'SAR',
      name: 'SAR',
    );
  }
  String get AddService {
    return Intl.message(
      'AddService',
      name: 'AddService',
    );
  }
  String get ServiceKind {
    return Intl.message(
      'ServiceKind',
      name: 'ServiceKind',
    );
  }

  String get ServicePrice {
    return Intl.message(
      'ServicePrice',
      name: 'ServicePrice',
    );
  }

  String get Total {
    return Intl.message(
      'Total',
      name: 'Total',
    );
  }


  String get Pay {
    return Intl.message(
      'Pay',
      name: 'Pay',
    );
  }
  String get MyServices {
    return Intl.message(
      'MyServices',
      name: 'MyServices',
    );
  }

  String get Visa {
    return Intl.message(
      'Visa',
      name: 'visa',
    );
  }
  String get Cash {
    return Intl.message(
      'Cash',
      name: 'cash',
    );
  }
  String get Wallet {
    return Intl.message(
      'Wallet',
      name: 'wallet',
    );
  }
  String get serviceRate {
    return Intl.message(
      'serviceRate',
      name: 'serviceRate',
    );
  }
  String get pleaseRate {
    return Intl.message(
      'pleaseRate',
      name: 'pleaseRate',
    );
  }
  String get rateQ {
    return Intl.message(
      'rateQ',
      name: 'rateQ',
    );
  }
  String get send {
    return Intl.message(
      'send',
      name: 'send',
    );
  }
  String get SelectServices {
    return Intl.message(
      'SelectServices',
      name: 'SelectServices',
    );
  }
  String get SelectStation {
    return Intl.message(
      'SelectStation',
      name: 'SelectStation',
    );
  }
  String get comment {
    return Intl.message(
      'comment',
      name: 'comment',
    );
  }
  String get order_number {
    return Intl.message(
      'order_number',
      name: 'order_number',
    );
  }
  String get date {
    return Intl.message(
      'date',
      name: 'date',
    );
  }
  String get status {
    return Intl.message(
      'status',
      name: 'status',
    );
  }
  String get order_details {
    return Intl.message(
      'order_details',
      name: 'order_details',
    );
  }

  String get serviceType {
    return Intl.message(
      'serviceType',
      name: 'serviceType',
    );
  }  String get serviceType1 {
    return Intl.message(
      'serviceType1',
      name: 'serviceType1',
    );
  }  String get serviceType2 {
    return Intl.message(
      'serviceType2',
      name: 'serviceType2',
    );
  }
 String get errorLocation {
    return Intl.message(
      'errorLocation',
      name: 'errorLocation',
    );
  }

  String get quantity {
    return Intl.message(
      'quantity',
      name: 'quantity',
    );
  }
  String get quantity_Validation {
    return Intl.message(
      'quantity_Validation',
      name: 'quantity_Validation',
    );
  }
  String get inquiry {
    return Intl.message(
      'inquiry',
      name: 'inquiry',
    );
  }
  String get complaint {
    return Intl.message(
      'complaint',
      name: 'complaint',
    );
  }
  String get suggestion {
    return Intl.message(
      'suggestion',
      name: 'suggestion',
    );
  }

  String get choose_Country {
    return Intl.message(
      'choose_Country',
      name: 'choose_Country',
    );
  }

  String get choose_City {
    return Intl.message(
      'choose_City',
      name: 'choose_City',
    );
  }
  String get station_location {
    return Intl.message(
      'station_location',
      name: 'station_location',
    );
  }
  String get Station_location {
    return Intl.message(
      'Station_location',
      name: 'Station_location',
    );
  } String get Station_name {
    return Intl.message(
      'Station_name',
      name: 'Station_name',
    );
  } String get Station_address {
    return Intl.message(
      'Station_address',
      name: 'Station_address',
    );
  }String get add_photo {
    return Intl.message(
      'add_photo',
      name: 'add_photo',
    );
  }
String get cancel {
    return Intl.message(
      'cancel',
      name: 'cancel',
    );
  }String get address {
    return Intl.message(
      'address',
      name: 'address',
    );
  }String get phone_number_ex {
    return Intl.message(
      'phone_number_ex',
      name: 'phone_number_ex',
    );
  }String get Transportation {
    return Intl.message(
      'Transportation',
      name: 'Transportation',
    );
  }String get gasType {
    return Intl.message(
      'gasType',
      name: 'gasType',
    );
  }
String get location_added {
  return Intl.message(
    'location_added',
    name: 'location_added',
  );
}

  String get accept {
    return Intl.message(
      'accept',
      name: 'accept',
    );
  }  String get not_accept {
    return Intl.message(
      'not_accept',
      name: 'not_accept',
    );
  }String get data_Validation {
    return Intl.message(
      'data_Validation',
      name: 'data_Validation',
    );
  }String get branches {
    return Intl.message(
      'branches',
      name: 'branches',
    );
  }
String get work_hours {
    return Intl.message(
      'work_hours',
      name: 'work_hours',
    );
  }
  String get Fuel_filling {
    return Intl.message(
      'Fuel_filling',
      name: 'Fuel_filling',
    );
  }
  String get Logistics_services {
    return Intl.message(
      'Logistics_services',
      name: 'Logistics_services',
    );
  }
  String get Fuel_transportation {
    return Intl.message(
      'Fuel_transportation',
      name: 'Fuel_transportation',
    );
  }
  String get Recharge_balance {
    return Intl.message(
      'Recharge_balance',
      name: 'Recharge_balance',
    );
  }
  String get balance {
    return Intl.message(
      'balance',
      name: 'balance',
    );
  }
  String get Recharge_wallet {
    return Intl.message(
      'Recharge_wallet',
      name: 'Recharge_wallet',
    );
  }
  String get Service_Evaluation {
    return Intl.message(
      'Service_Evaluation',
      name: 'Service_Evaluation',
    );
  }
  String get Loyalty_System {
    return Intl.message(
      'Loyalty_System',
      name: 'Loyalty_System',
    );
  }
  String get Electronic_Wallet {
    return Intl.message(
      'Electronic_Wallet',
      name: 'Electronic_Wallet',
    );
  }
  String get our_values {
    return Intl.message(
      'our_values',
      name: 'our_values',
    );
  }
  String get our_vision {
    return Intl.message(
      'our_vision',
      name: 'our_vision',
    );
  }
  String get our_mission {
    return Intl.message(
      'our_mission',
      name: 'our_mission',
    );
  }
  String get our_slogan {
    return Intl.message(
      'our_slogan',
      name: 'our_slogan',
    );
  } String get Points_balance {
    return Intl.message(
      'Points_balance',
      name: 'Points_balance',
    );
  }
  String get Wallet_balance {
    return Intl.message(
      'Wallet_balance',
      name: 'Wallet_balance',
    );
  } String get Offers_discounts {
    return Intl.message(
      'Offers_discounts',
      name: 'Offers_discounts',
    );
  }
String get get_Offer {
    return Intl.message(
      'get_Offer',
      name: 'get_Offer',
    );
  }

String get Point {
    return Intl.message(
      'Point',
      name: 'Point',
    );
  }

String get get_Point {
    return Intl.message(
      'get_Point',
      name: 'get_Point',
    );
  }
String get amount {
    return Intl.message(
      'amount',
      name: 'amount',
    );
  }
String get enter_amount {
    return Intl.message(
      'enter_amount',
      name: 'enter_amount',
    );
  }
  String get des {
    return Intl.message(
      'des',
      name: 'des',
    );
  }
  String get enter_des {
    return Intl.message(
      'enter_des',
      name: 'enter_des',
    );
  } String get enter_amount_valid {
    return Intl.message(
      'enter_amount_valid',
      name: 'enter_amount_valid',
    );
  } String get replacement_point {
    return Intl.message(
      'replacement_point',
      name: 'replacement_point',
    );
  }String get try_again {
    return Intl.message(
      'try_again',
      name: 'try_again',
    );
  }String get edit_data {
    return Intl.message(
      'edit_data',
      name: 'edit_data',
    );
  }String get new_noData {
    return Intl.message(
      'new_noData',
      name: 'new_noData',
    );
  }String get ScanQrcode {
    return Intl.message(
      'ScanQrcode',
      name: 'ScanQrcode',
    );
  }
  String get delete_account {
    return Intl.message(
      'delete_account',
      name: 'delete_account',
    );
  }
  String get warning {
    return Intl.message(
      'warning',
      name: 'warning',
    );
  }
  String get delete_msg {
    return Intl.message(
      'delete_msg',
      name: 'delete_msg',
    );
  }
  String get delete_msg1 {
    return Intl.message(
      'delete_msg1',
      name: 'delete_msg1',
    );
  }
  String get delete_msg2 {
    return Intl.message(
      'delete_msg2',
      name: 'delete_msg2',
    );
  }
  String get delete_msg3 {
    return Intl.message(
      'delete_msg3',
      name: 'delete_msg3',
    );
  } String get phone_invalid {
    return Intl.message(
      'phone_invalid',
      name: 'phone_invalid',
    );
  }String get name_Validation {
    return Intl.message(
      'name_Validation',
      name: 'name_Validation',
    );
  }String get verifyAccount {
    return Intl.message(
      'verifyAccount',
      name: 'verifyAccount',
    );
  }
String get remainingTime {
    return Intl.message(
      'remainingTime',
      name: 'remainingTime',
    );
  }
String get verificationCode_Validation {
    return Intl.message(
      'verificationCode_Validation',
      name: 'verificationCode_Validation',
    );
  }
String get verificationCode {
    return Intl.message(
      'verificationCode',
      name: 'verificationCode',
    );
  }String get verifyToEmail {
    return Intl.message(
      'verifyToEmail',
      name: 'verifyToEmail',
    );
  }String get resendCode {
    return Intl.message(
      'resendCode',
      name: 'resendCode',
    );
  }String get EmailorMobile {
    return Intl.message(
      'EmailorMobile',
      name: 'EmailorMobile',
    );
  }String get EmailorMobile_Validation {
    return Intl.message(
      'EmailorMobile_Validation',
      name: 'EmailorMobile_Validation',
    );
  }

  String get help {
    return Intl.message(
      'help',
      name: 'help',
    );
  }
  String get sendMsg {
    return Intl.message(
      'sendMsg',
      name: 'sendMsg',
    );
  } String get contactWebSite {
    return Intl.message(
      'contactWebSite',
      name: 'contactWebSite',
    );
  }
  String get webSite {
    return Intl.message(
      'webSite',
      name: 'webSite',
    );
  }
  String get contactWhatsApp {
    return Intl.message(
      'contactWhatsApp',
      name: 'contactWhatsApp',
    );
  }
  String get whatsApp {
    return Intl.message(
      'whatsApp',
      name: 'whatsApp',
    );
  }
  String get currentPassword {
    return Intl.message(
      'currentPassword',
      name: 'currentPassword',
    );
  } String get newPassword {
    return Intl.message(
      'newPassword',
      name: 'newPassword',
    );
  }String get scanQr {
    return Intl.message(
      'scanQr',
      name: 'scanQr',
    );
  }String get Station_Evaluation {
    return Intl.message(
      'Station_Evaluation',
      name: 'Station_Evaluation',
    );
  }String get search {
    return Intl.message(
      'search',
      name: 'search',
    );
  }  String get AnswerValidation {
    return Intl.message(
      'AnswerValidation',
      name: 'AnswerValidation',
    );
  }
  String get yes {
    return Intl.message(
      'yes',
      name: 'yes',
    );
  }
  String get no {
    return Intl.message(
      'no',
      name: 'no',
    );
  }
  String get writeSuggestion {
    return Intl.message(
      'writeSuggestion',
      name: 'writeSuggestion',
    );
  }
  String get writeThanksMessage {
    return Intl.message(
      'writeThanksMessage',
      name: 'writeThanksMessage',
    );
  }
  String get submitEvaluation {
    return Intl.message(
      'submitEvaluation',
      name: 'submitEvaluation',
    );
  }
  String get evaluationSentSuccessfully {
    return Intl.message(
      'evaluationSentSuccessfully',
      name: 'evaluationSentSuccessfully',
    );
  }

}
