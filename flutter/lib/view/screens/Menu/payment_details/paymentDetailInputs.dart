import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/payments_detail_controller.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/text.dart';

class PaymentDetailInputs extends StatefulWidget {
  PaymentDetailController paymentDetailController;
  PaymentDetailInputs({super.key, required this.paymentDetailController});

  @override
  State<PaymentDetailInputs> createState() => _PaymentDetailInputsState();
}

class _PaymentDetailInputsState extends State<PaymentDetailInputs> {
  TextEditingController bankName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController accountName = TextEditingController();
  TextEditingController paypalEmail = TextEditingController();
  TextEditingController countrySpecificFieldController = TextEditingController();

  GlobalKey<FormState> formKeyBankDetails = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyAddPaypal = GlobalKey<FormState>();

  String selectedOption1 = 'bank_transfer';
  String selectedCountry = '';
  List<String> availableCountries = [];
  List<String> options1 = ['bank_transfer', 'paypal'];
  final List<String> defaultCountries = [
    'US','PE','MX','CO','AR','CL','EC','VE','BR','BO','PY','UY','CR','PA','DO','SV','GT','HN','NI','PR',
    'ES','PT','FR','DE','IT','NL','BE','CH','AT','IE','GB','SE','NO','DK','FI','IS','RO','BG','GR','HU','CZ','PL',
    'TR','AE','SA','EG','MA','ZA',
    'IN','PK','BD','JP','KR','CN','HK','TW','SG','MY','ID','TH','PH','VN',
    'AU','NZ','CA'
  ];
  final Map<String, String> countryNames = {
    'US': 'Estados Unidos',
    'PE': 'Perú',
    'MX': 'México',
    'CO': 'Colombia',
    'AR': 'Argentina',
    'CL': 'Chile',
    'EC': 'Ecuador',
    'VE': 'Venezuela',
    'BR': 'Brasil',
    'BO': 'Bolivia',
    'PY': 'Paraguay',
    'UY': 'Uruguay',
    'CR': 'Costa Rica',
    'PA': 'Panamá',
    'DO': 'República Dominicana',
    'SV': 'El Salvador',
    'GT': 'Guatemala',
    'HN': 'Honduras',
    'NI': 'Nicaragua',
    'PR': 'Puerto Rico',
    'IN': 'India',
    'GB': 'Reino Unido',
    'AU': 'Australia',
    'CA': 'Canadá',
    'DE': 'Alemania',
    'ES': 'España',
    'PT': 'Portugal',
    'FR': 'Francia',
    'CN': 'China',
    'SG': 'Singapur',
    'HK': 'Hong Kong',
    'NZ': 'Nueva Zelanda',
    'IT': 'Italia',
    'NL': 'Países Bajos',
    'BE': 'Bélgica',
    'CH': 'Suiza',
    'AT': 'Austria',
    'IE': 'Irlanda',
    'SE': 'Suecia',
    'NO': 'Noruega',
    'DK': 'Dinamarca',
    'FI': 'Finlandia',
    'IS': 'Islandia',
    'RO': 'Rumania',
    'BG': 'Bulgaria',
    'GR': 'Grecia',
    'HU': 'Hungría',
    'CZ': 'Chequia',
    'PL': 'Polonia',
    'TR': 'Turquía',
    'AE': 'Emiratos Árabes Unidos',
    'SA': 'Arabia Saudita',
    'EG': 'Egipto',
    'MA': 'Marruecos',
    'ZA': 'Sudáfrica',
    'PK': 'Pakistán',
    'BD': 'Bangladés',
    'JP': 'Japón',
    'KR': 'Corea del Sur',
    'TW': 'Taiwán',
    'MY': 'Malasia',
    'ID': 'Indonesia',
    'TH': 'Tailandia',
    'PH': 'Filipinas',
    'VN': 'Vietnam'
  };

  String flagEmoji(String code) {
    if (code.length != 2) return '';
    final upper = code.toUpperCase();
    const int base = 0x1F1E6;
    final int first = upper.codeUnitAt(0) - 65;
    final int second = upper.codeUnitAt(1) - 65;
    return String.fromCharCode(base + first) + String.fromCharCode(base + second);
  }

  // Map for country-specific field labels
  Map<String, String> countrySpecificFieldLabels = {
    'US': 'Número de Ruta',
    'IN': 'Código IFSC',
    'GB': 'Código Sort',
    'AU': 'Número BSB',
    'CA': 'Número de Tránsito/Institución',
    'DE': 'IBAN/BIC',
    'CN': 'Código CNAPS',
    'SG': 'Código SWIFT',
    'HK': 'Código de Compensación',
    'NZ': 'Número de Sucursal Bancaria',
    'ES': 'IBAN/BIC',
    'FR': 'IBAN/BIC',
    'IT': 'IBAN/BIC',
    'NL': 'IBAN/BIC',
    'BE': 'IBAN/BIC',
    'CH': 'IBAN/BIC',
    'AT': 'IBAN/BIC',
    'IE': 'IBAN/BIC',
    'PT': 'IBAN/BIC',
    'GR': 'IBAN/BIC',
    'PL': 'IBAN/BIC',
    'CZ': 'IBAN/BIC',
    'HU': 'IBAN/BIC',
    'RO': 'IBAN/BIC',
    'BG': 'IBAN/BIC',
    'SE': 'IBAN/BIC',
    'NO': 'IBAN/BIC',
    'DK': 'IBAN/BIC',
    'FI': 'IBAN/BIC',
    'IS': 'IBAN/BIC',
  };

  // Map for country-specific field keys (matching backend)
  Map<String, String> countrySpecificFieldKeys = {
    'US': 'payment_routing_number',
    'IN': 'payment_ifsc_code',
    'GB': 'payment_sort_code',
    'AU': 'payment_bsb_number',
    'CA': 'payment_transit_institution_number',
    'DE': 'payment_iban_bic',
    'CN': 'payment_cnaps_code',
    'SG': 'payment_swift_code',
    'HK': 'payment_clearing_code',
    'NZ': 'payment_bank_branch_number',
    'ES': 'payment_iban_bic',
    'FR': 'payment_iban_bic',
    'IT': 'payment_iban_bic',
    'NL': 'payment_iban_bic',
    'BE': 'payment_iban_bic',
    'CH': 'payment_iban_bic',
    'AT': 'payment_iban_bic',
    'IE': 'payment_iban_bic',
    'PT': 'payment_iban_bic',
    'GR': 'payment_iban_bic',
    'PL': 'payment_iban_bic',
    'CZ': 'payment_iban_bic',
    'HU': 'payment_iban_bic',
    'RO': 'payment_iban_bic',
    'BG': 'payment_iban_bic',
    'SE': 'payment_iban_bic',
    'NO': 'payment_iban_bic',
    'DK': 'payment_iban_bic',
    'FI': 'payment_iban_bic',
    'IS': 'payment_iban_bic',
  };

  @override
  void dispose() {
    bankName.dispose();
    accountName.dispose();
    accountNumber.dispose();
    paypalEmail.dispose();
    countrySpecificFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var data = widget.paymentDetailController.PaymentDetailData!.data;
    setState(() {
      bankName.text = data.paymentList.paymentBankName;
      accountNumber.text = data.paymentList.paymentAccountNumber;
      accountName.text = data.paymentList.paymentAccountName;
      paypalEmail.text = data.paypalAccounts.paypalEmail;
      selectedOption1 = data.primaryPaymentMethod == 'bank_transfer'
          ? 'bank_transfer'
          : 'paypal';
      selectedCountry = data.paymentList.paymentCountry;
      availableCountries = (data.availableCountries.isNotEmpty) ? data.availableCountries : defaultCountries;

      // Set the country-specific field if it exists
      if (selectedCountry.isNotEmpty && countrySpecificFieldKeys.containsKey(selectedCountry)) {
        String fieldKey = countrySpecificFieldKeys[selectedCountry]!;
        // Get the value dynamically based on the field name
        String? value;

        switch(fieldKey) {
          case 'payment_routing_number':
            value = data.paymentList.paymentRoutingNumber;
            break;
          case 'payment_ifsc_code':
            value = data.paymentList.paymentIfscCode;
            break;
          case 'payment_sort_code':
            value = data.paymentList.paymentSortCode;
            break;
          case 'payment_bsb_number':
            value = data.paymentList.paymentBsbNumber;
            break;
          case 'payment_transit_institution_number':
            value = data.paymentList.paymentTransitInstitutionNumber;
            break;
          case 'payment_iban_bic':
            value = data.paymentList.paymentIbanBic;
            break;
          case 'payment_cnaps_code':
            value = data.paymentList.paymentCnapsCode;
            break;
          case 'payment_swift_code':
            value = data.paymentList.paymentSwiftCode;
            break;
          case 'payment_clearing_code':
            value = data.paymentList.paymentClearingCode;
            break;
          case 'payment_bank_branch_number':
            value = data.paymentList.paymentBankBranchNumber;
            break;
        }

        if (value != null) {
          countrySpecificFieldController.text = value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildSection(
          formKey: formKeyBankDetails,
          title: AppText.bankDetails,
          children: [
            _textField(AppText.bankName, bankName, Icons.account_balance_outlined),
            _textField(AppText.accountNumber, accountNumber, Icons.pin_outlined),
            _textField(AppText.accountName, accountName, Icons.person_outline),

            // Country Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1A1D1A),
                decoration: _dropdownDecoration('Seleccionar País', Icons.public),
                isExpanded: true,
                menuMaxHeight: 240,
                value: selectedCountry.isNotEmpty ? selectedCountry : null,
                items: availableCountries.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      '${flagEmoji(value)} ${countryNames[value] ?? value} ($value)',
                      style: const TextStyle(
                          color: AppColor.appWhite,
                          fontFamily: 'Poppins',
                          fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value!;
                    if (countrySpecificFieldKeys.containsKey(selectedCountry)) {
                      String fieldKey = countrySpecificFieldKeys[selectedCountry]!;
                      var data = widget.paymentDetailController.PaymentDetailData!.data;
                      String? value;
                      switch (fieldKey) {
                        case 'payment_routing_number': value = data.paymentList.paymentRoutingNumber; break;
                        case 'payment_ifsc_code': value = data.paymentList.paymentIfscCode; break;
                        case 'payment_sort_code': value = data.paymentList.paymentSortCode; break;
                        case 'payment_bsb_number': value = data.paymentList.paymentBsbNumber; break;
                        case 'payment_transit_institution_number': value = data.paymentList.paymentTransitInstitutionNumber; break;
                        case 'payment_iban_bic': value = data.paymentList.paymentIbanBic; break;
                        case 'payment_cnaps_code': value = data.paymentList.paymentCnapsCode; break;
                        case 'payment_swift_code': value = data.paymentList.paymentSwiftCode; break;
                        case 'payment_clearing_code': value = data.paymentList.paymentClearingCode; break;
                        case 'payment_bank_branch_number': value = data.paymentList.paymentBankBranchNumber; break;
                      }
                      countrySpecificFieldController.text = value ?? '';
                    } else {
                      countrySpecificFieldController.clear();
                    }
                  });
                },
                validator: (value) => (value == null || value.isEmpty) ? 'El país es obligatorio' : null,
              ),
            ),

            if (selectedCountry.isNotEmpty && countrySpecificFieldLabels.containsKey(selectedCountry))
              _textField(
                countrySpecificFieldLabels[selectedCountry]!,
                countrySpecificFieldController,
                Icons.info_outline,
              ),

            GestureDetector(
              onTap: () {
                if (formKeyBankDetails.currentState!.validate()) {
                  Map<String, String> countrySpecificFields = <String, String>{};
                  if (selectedCountry.isNotEmpty &&
                      countrySpecificFieldKeys.containsKey(selectedCountry) &&
                      countrySpecificFieldController.text.isNotEmpty) {
                    countrySpecificFields[countrySpecificFieldKeys[selectedCountry]!] =
                        countrySpecificFieldController.text;
                  }
                  Get.find<PaymentDetailController>().addBankAccount(
                    bankName.text, accountNumber.text, accountName.text, selectedCountry, countrySpecificFields,
                  );
                }
              },
              child: CustomButton(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _buildSection(
          formKey: formKeyAddPaypal,
          title: AppText.addPaypalAccount,
          children: [
            _textField(AppText.paypalEmail, paypalEmail, Icons.email_outlined),
            GestureDetector(
              onTap: () {
                if (formKeyAddPaypal.currentState!.validate()) {
                  Get.find<PaymentDetailController>().addPaypalAccount(paypalEmail.text);
                }
              },
              child: CustomButton(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _buildSection(
          title: AppText.primaryPaymentMethod,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1A1D1A),
                decoration: _dropdownDecoration('Select Method', Icons.payments_outlined),
                value: selectedOption1,
                menuMaxHeight: 240,
                items: options1.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      convertSnakeCaseToTitleCase(value),
                      style: const TextStyle(
                          color: AppColor.appWhite,
                          fontFamily: 'Poppins',
                          fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedOption1 = newValue!;
                  });
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.find<PaymentDetailController>().addPrimaryPaymentMethod(selectedOption1);
              },
              child: CustomButton(),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children, GlobalKey<FormState>? formKey}) {
    return Container(
      decoration: _boxDecoration(),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _titleText(title),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _titleText(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColor.appPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _textField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label, 
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500
              )
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppColor.appPrimary, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontFamily: 'Poppins'),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null,
              style: const TextStyle(color: AppColor.appWhite, fontFamily: 'Poppins', fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint, IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: AppColor.appPrimary, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    filled: true,
    fillColor: Colors.white.withOpacity(0.03),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColor.appPrimary),
    ),
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontFamily: 'Poppins', fontSize: 14),
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: const Color(0xFF151515),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: Colors.white.withOpacity(0.05)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
  );

  Widget CustomButton() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
    child: Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.appPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.appPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Enviar',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
  );

  String convertSnakeCaseToTitleCase(String input) {
    List<String> words = input.split('_');
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isEmpty) continue;
      String capitalizedWord = word[0].toUpperCase() + word.substring(1);
      capitalizedWords.add(capitalizedWord);
    }

    return capitalizedWords.join(' ');
  }
}
