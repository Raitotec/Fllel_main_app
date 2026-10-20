import 'package:flutter/material.dart';
import 'package:babco/Models/ServicesModel.dart';

import '../Localization/Translations.dart';
import '../Models/PaymentModel.dart';

List<PaymentModel> GetPayment(BuildContext context)
{

  var PaymentList= <PaymentModel>[];

  PaymentList.add(new PaymentModel(2, Translations.of(context)!.Cash, "i11", null,true));
  PaymentList.add(new PaymentModel(1, Translations.of(context)!.Visa, "i7", "i8",false));
  PaymentList.add(new PaymentModel(3, Translations.of(context)!.Wallet, "i10", null,false));

  return PaymentList;
}