// ignore_for_file: constant_identifier_names

import 'package:finders_v1_1/Service_Provider/service_Appointment.dart';
import 'package:finders_v1_1/cipc.dart';
import 'package:finders_v1_1/Client/all_companies.dart';

import 'package:finders_v1_1/Client/client_pro.dart';
import 'package:finders_v1_1/Client/client_profile.dart';
import 'package:finders_v1_1/about_us.dart';
import 'package:finders_v1_1/Client/appointment_page.dart';
import 'package:finders_v1_1/Client/client_details.dart';
import 'package:finders_v1_1/Client/client_home.dart';
import 'package:finders_v1_1/Client/client_login.dart';
import 'package:finders_v1_1/Client/client_reg.dart';
import 'package:finders_v1_1/Client/contact_us.dart';
import 'package:finders_v1_1/splash.dart';
import 'package:finders_v1_1/main_page.dart';
import 'package:finders_v1_1/Service_Provider/provider_profile.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_home.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_login.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_reg.dart';
import 'package:flutter/material.dart';

//   a main landing page

class RouteManager {
  static const String mainPage = '/';
  static const String splash = '/splash';
  static const String clientHomePage = '/clientHomePage';
  static const String allCompaniesPage = '/allCompaniesPage';
  static const String cipc = '/cipc';

  static const String payment = '/paymentPage';
  static const String clientLoginPage = '/clientLoginPage';
  static const String clientRegistrationPage = '/clientRegistrationPage';
  static const String serviceProviderHomePage = '/serviceProviderHomePage';
  static const String serviceProviderLoginPage = '/serviceProviderLoginPage';
  static const String partnerRegistrationPage = '/partnerRegistrationPage';
  static const String profilePage = '/profilePage';
  static const String serviceProfilePage = '/serviceProfilePage';
  static const String proPicPage = '/proPicPage';
  static const String appointmentPage = '/appointmentPage';
  static const String service_appointmentPage = '/service_appointmentPage';
  static const String detailsPage = '/detailsPage';
  static const String aboutUsPage = '/aboutUsPage';
  static const String contactUsPage = '/contactUsPage';
  static const String bookingPage = '/bookingPage';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainPage:
        return MaterialPageRoute(builder: (context) => const MainPage());
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case service_appointmentPage:
        return MaterialPageRoute(
            builder: (context) => const ServiceProviderAppointmentPage());
      case clientHomePage:
        return MaterialPageRoute(builder: (context) => const ClientHomePage());
      case clientLoginPage:
        return MaterialPageRoute(builder: (context) => const ClientLoginPage());
      case cipc:
        return MaterialPageRoute(builder: (context) => Cipc());

      case clientRegistrationPage:
        return MaterialPageRoute(
            builder: (context) => const ClientRegistrationPage());

      case appointmentPage:
        return MaterialPageRoute(builder: (context) => const AppointmentPage());

      case detailsPage:
        var appointmentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => DetailsPage(appointmentId: appointmentId),
        );
      case serviceProviderHomePage:
        return MaterialPageRoute(
            builder: (context) => const ServiceProviderHome());
      case serviceProviderLoginPage:
        return MaterialPageRoute(
            builder: (context) => const ServiceProviderLoginPage());
      case partnerRegistrationPage:
        return MaterialPageRoute(
            builder: (context) => const PartnerRegistrationPage());
      case serviceProfilePage:
        return MaterialPageRoute(
            builder: (context) => const ServiceProfilePage());
      case allCompaniesPage:
        return MaterialPageRoute(
            builder: (context) => const AllCompaniesPage());

      case profilePage:
        return MaterialPageRoute(builder: (context) => const ProfilePage());
      case proPicPage:
        return MaterialPageRoute(builder: (context) => const ProPicPage());
      case aboutUsPage:
        return MaterialPageRoute(builder: (context) => const AboutUsPage());
      case contactUsPage:
        return MaterialPageRoute(builder: (context) => const ContactUsPage());
      default:
        throw Exception('Route not found');
    }
  }
}
