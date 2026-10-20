
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Views/Evaluation/ServiceEvaluationPage.dart';
import 'package:babco/Views/Evaluation/StationEvaluationPage.dart';
import 'package:babco/Views/LoginPages/otp_code_page.dart';
import 'package:babco/Views/LoginPages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:babco/Models/DataModel.dart';
import 'package:babco/Models/MainModel.dart';
import 'package:babco/Models/RequestsModel.dart';
import 'package:babco/Models/ServicesModel.dart';
import 'package:babco/Views/ServicesReviewsPage.dart';
import 'package:babco/Views/balance_page.dart';
import 'package:babco/Views/new_service_page.dart';
import 'package:babco/Views/services_details_page.dart';
import 'package:babco/Views/services_page.dart';
import 'package:babco/Views/splashPage.dart';
import '../Views/ClientServicePage.dart';
import '../Views/PersonInformationPage.dart';
import '../Views/RequestsDetails.dart';
import '../Views/RequestsPage.dart';
import '../Views/StationMaintenancePage.dart';
import '../Views/StationReviewsPage.dart';
import '../Views/StationTransportationPage.dart';
import '../Views/about_us_page.dart';
import '../Views/contact_us_page.dart';
import '../Views/deleteAccountPage.dart';
import '../Views/location_station.dart';
import '../Views/loyalty_page.dart';
import '../Views/map_location_page.dart';
import '../Views/map_page.dart';
import '../Views/new_offer_page.dart';
import '../Shared_Data/DelegateData.dart';
import '../Views/home_page.dart';
import '../Views/LoginPages/login_page.dart';
import '../Views/not_found_page.dart';
import '../Views/pay_page.dart';
import '../Views/rate_page.dart';
import '../Views/services_selected_page.dart';
import 'route_constants.dart';
class CustomRouter {
  static Route<dynamic> generatedRoute(RouteSettings settings) {
    switch (settings.name) {
      case startRoute:
        try {

          if (DelegateData.delegateData != null && DelegateData.delegateData?.name!= null ) {
            return MaterialPageRoute(builder: (_) => HomePage());
          }
          else {
            return MaterialPageRoute(builder: (_) => LoginPage());
          }
        }
        catch(e){
          return MaterialPageRoute(builder: (_) => LoginPage());
        }
      case loginRoute:
          return MaterialPageRoute(builder: (_) => LoginPage());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => HomePage());
      case deleteAccountRoute:
        return MaterialPageRoute(builder: (_) => deleteAccountPage());
      case splashRoute:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case BalanceRoute:
        return MaterialPageRoute(builder: (_) => BalancePage());
      case newUserRoute:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case NewServiceRoute:
        {
          final args= settings.arguments as DataModel;
          return MaterialPageRoute(builder: (_) => NewServicesPage(data: args,));
        }
      case mapScreenRoute:
        return MaterialPageRoute(builder: (_) => MapScreen());
      case serviceRoute:
        {
          final args= settings.arguments as String;
          return MaterialPageRoute(builder: (_) => ServicesPage(id:args));
        }
      case serviceDetailsRoute:
        {
          final args= settings.arguments as List<ServicesModel>;
          return MaterialPageRoute(builder: (_) => ServicesDetailsPage(obj: args));
        }
      case serviceSelectedPageRoute:
        {
          final args= settings.arguments as List<ServicesModel>;
          return MaterialPageRoute(builder: (_) => ServicesSelectedPage(obj: args));
        }
      case PayPageRoute:
        {
          final args= settings.arguments as List<ServicesModel>;
          return MaterialPageRoute(builder: (_) => PayPage(obj: args));
        }
        case RatePageRoute:
        {
          final args= settings.arguments as String;
          return MaterialPageRoute(builder: (_) => RatePage(obj: args));
        }
      case StationMaintenancePageRoute:
        {
          return MaterialPageRoute(builder: (_) => StationMaintenancePage());
        }
      case ClientServicePageRoute:
        {
          return MaterialPageRoute(builder: (_) => ClientServicePage());
        }
      case RequestsRoute:
        {
          return MaterialPageRoute(builder: (_) => RequestsPage());
        }
      case PersonInformationRoute:
        {
          return MaterialPageRoute(builder: (_) => PersonInformationPage());
        }
      case Connect_usRoute:
        {
          return MaterialPageRoute(builder: (_) => ConnectUsPage());
        }
      case AboutUsRoute:
        {
          return MaterialPageRoute(builder: (_) => AboutUsPage());
        }
      case RequestsDetailsRoute:
        {
          final args= settings.arguments as RequestsModel;
          return MaterialPageRoute(builder: (_) => RequestsDetailsPage(obj: args));
        }
      case station_locationRoute:
        {
          return MaterialPageRoute(builder: (_) => MapLocationStationScreen());
        }
        case StationReviewsRoute:
        {
          return MaterialPageRoute(builder: (_) => StationReviewsPage());
        }
        case ServicesReviewsRoute:
        {
          return MaterialPageRoute(builder: (_) => ServicesReviewsPage());
        }
        case StationTransportationRoute:
        {
          return MaterialPageRoute(builder: (_) => StationTransportationPage());
        }
      case MapLocationRoute:
        {
          return MaterialPageRoute(builder: (_) => MapLocationScreen());
        }
        case LoyaltySystemRoute:
        {
          return MaterialPageRoute(builder: (_) => LoyaltySystemPage());
        }
        case StationEvaluationRoute:
        {
          return MaterialPageRoute(builder: (_) => StationEvaluationPage());
        }
        case ServiceEvaluationRoute:
        {
          return MaterialPageRoute(builder: (_) => ServiceEvaluationPage());
        }
        case NewOfferRoute:
        {
          final args= settings.arguments as OffersAndDiscounts;
          return MaterialPageRoute(builder: (_) => NewOfferPage(data: args,));
        }
      case verifyCodeRoute:
        {
          final args= settings.arguments as DelegateDataModel;
          return MaterialPageRoute(builder: (_) => OtpPage(data: args,));
        }
      default:
        return MaterialPageRoute(builder: (_) => NotFoundPage());
    }
  }
}
