import 'package:flutter/material.dart';
import 'Service_Provider/service_provider_login.dart';
import 'Client/client_login.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top blue container with "FINDERS" text
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            color: Colors.blueAccent,
            child: const Center(
              child: Text(
                'FINDERS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Login buttons
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClientLoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300], // Grey color for button
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('LOGIN AS CLIENT')),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ServiceProviderLoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300], // Grey color for button
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('LOGIN AS PARTNER')),
                  ),
                ),
              ),
            ],
          ),

          // Bottom blue container with version text
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            color: Colors.blueAccent,
            child: const Center(
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
