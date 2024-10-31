// ignore_for_file: avoid_types_as_parameter_names, use_super_parameters, no_leading_underscores_for_local_identifiers, unused_element, camel_case_types, non_constant_identifier_names

import 'package:flutter/material.dart';

class BankingDetails {
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String branchCode;

  BankingDetails({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.branchCode,
  });
}


class BankingDetailsForm extends StatefulWidget {
  const BankingDetailsForm({Key? key, required String bankName, required String accountNumber, required String branchCode, Map<String, dynamic>? bankingDetails}) : super(key: key);

  @override
  BankingDetailsFormState createState() => BankingDetailsFormState();
  void setBankingDetails(Map<String, dynamic> bankingDetails,TextEditingController, TextEditingController _accountNumberController, TextEditingController _branchCodeController, TextEditingController _accountHolderController, TextEditingController _bankNameController) {
    _bankNameController.text = bankingDetails['bankName'] ?? '';
    _accountNumberController.text = bankingDetails['accountNumber'] ?? '';
    _branchCodeController.text = bankingDetails['branchCode'] ?? '';
    _accountHolderController.text = bankingDetails['accountHolder'] ?? '';
  }

    Map<String, dynamic> getBankingDetails(TextEditingController _bankNameController,TextEditingController _accountNumberController,TextEditingController _branchCodeController, TextEditingController _accountHolderController) {
    return {
      'bankName': _bankNameController.text.trim(),
      'accountNumber': _accountNumberController.text.trim(),
      'branchCode': _branchCodeController.text.trim(),
      'accountHolder': _accountHolderController.text.trim(),
    };
  }
}

class _accountNumberController {
}

class BankingDetailsFormState extends State<BankingDetailsForm> {
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();

  String? _selectedBank;

  final List<String> _bankNames = [
    'Capitec Pay',
    'FNB',
    'Absa',
    'Standard Bank',
    'NedBank',
  ];

  BankingDetails getBankingDetails(Map<String, dynamic>? bankingDetails, param1, Type textEditingController) {
    return BankingDetails(
      bankName: _selectedBank ?? '',
      accountHolder: _accountHolderController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      branchCode: _branchCodeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank Name Dropdown
        DropdownButtonFormField<String>(
          value: _selectedBank,
          hint: const Text('Select Bank'),
          items: _bankNames.map((String bank) {
            return DropdownMenuItem<String>(
              value: bank,
              child: Text(bank),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBank = newValue;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),

        // Account Holder Text Field
        TextField(
          controller: _accountHolderController,
          decoration: const InputDecoration(
            labelText: 'Account Holder',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),

        // Account Number Text Field
        TextField(
          maxLength: 13,
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),

        // Branch Code Text Field
        TextField(
          controller: _branchCodeController,
          decoration: const InputDecoration(
            labelText: 'Branch Code',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  void setBankingDetails(bankingDetails) {}
}
