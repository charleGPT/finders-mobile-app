// ignore_for_file: constant_identifier_names, unused_import

import 'package:finders_v1_1/Client/screens/client_home.dart';
import 'package:finders_v1_1/Client/screens/faqs_page.dart';
import 'package:finders_v1_1/Service_Provider/service_Appointment.dart';
import 'package:finders_v1_1/Service_Provider/service_details.dart';
import 'package:finders_v1_1/Service_Provider/service_info.dart';
import 'package:finders_v1_1/cipc.dart';
import 'package:finders_v1_1/Client/screens/all_companies.dart';

import 'package:finders_v1_1/Client/screens/client_pro.dart';
import 'package:finders_v1_1/Client/screens/client_profile.dart';
import 'package:finders_v1_1/about_us.dart';
import 'package:finders_v1_1/Client/screens/appointment_page.dart';
import 'package:finders_v1_1/Client/screens/client_details.dart';
import 'package:finders_v1_1/Client/screens/client_login.dart';
import 'package:finders_v1_1/Client/screens/client_reg.dart';
import 'package:finders_v1_1/Client/screens/contact_us.dart';
import 'package:finders_v1_1/splash.dart';
import 'package:finders_v1_1/main_page.dart';
import 'package:finders_v1_1/Service_Provider/provider_profile.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_home.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_login.dart';
import 'package:finders_v1_1/Service_Provider/service_provider_reg.dart';
import 'package:flutter/material.dart';

class RouteManager {
  //   a main landing page
  static const String mainPage = '/';
  static const String splash = '/splash';
  static const String serviceDetailsPage = '/serviceDetailsPage';
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
  static const String faqsPage = '/faqsPage';
  static const String serviceInfo = '/serviceInfo';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainPage:
        return MaterialPageRoute(builder: (context) => const MainPage());
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case faqsPage:
        return MaterialPageRoute(builder: (context) => const FAQsPage());
      case service_appointmentPage:
        return MaterialPageRoute(
            builder: (context) => const ServiceProviderAppointmentPage(
                  companyName: '',
                ));
      case clientHomePage:
        return MaterialPageRoute(
            builder: (context) => const ClientHomePage(
                  companyName: '',
                  providerId: '',
                  serviceProviderId: '',
                  address: '',
                  services: [], clientId: '',
                  //  prices: [],
                ));
      case clientLoginPage:
        return MaterialPageRoute(builder: (context) => const ClientLoginPage());
      case cipc:
        return MaterialPageRoute(builder: (context) => Cipc());

      case clientRegistrationPage:
        return MaterialPageRoute(
            builder: (context) => const ClientRegistrationPage());

      case serviceDetailsPage:
        return MaterialPageRoute(
            builder: (context) => const ServiceDetailsPage(
                  appointmentReference: '',
                ));

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
            builder: (context) => ServiceProfilePage(
                  serviceProviderId: '',
                  companyName: '',
                ));
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
      case serviceInfo:
        return MaterialPageRoute(
            builder: (context) => ServiceProviderDetailsPage(
                  companyName: '',
                  address: '',
                  services: [],
                  // prices: [],
                  serviceProviderId: '',
                ));
      default:
        throw Exception('Route not found');
    }
  }
}
