import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/wallet_controller.dart';
import '../../../../utils/colors.dart';

class FilterWidget extends StatefulWidget {
  final String parameter1;
  final String parameter2;
  final List<String> options1;
  final List<String> options2;
  final Function(String, String) onFilterChanged;
  final WalletController controller;

  const FilterWidget(
      {super.key, required this.parameter1,
      required this.parameter2,
      required this.options1,
      required this.options2,
      required this.onFilterChanged,
      required this.controller});

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String selectedOption1 = 'paid';
  String selectedOption2 = 'actions';
  updatePaid(
    String? paidStatus,
  ) {
    Get.find<WalletController>().updateActionAndPaid(paidStatus:paidStatus);
  }
  updatetype(
    String? type,
  ) {
    Get.find<WalletController>().updateActionAndPaid(type:type);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.appPrimary.withOpacity(0.4), width: 0.6), // Fine Green Neon border
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  icon:
                      const Icon(Icons.keyboard_arrow_down, color: AppColor.appPrimary, size: 20),
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.032,
                      color: Colors.white, // White Pure
                      fontWeight: FontWeight.bold),
                  dropdownColor: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  value: widget.controller.paid,
                  onChanged: (newValue) {
                    setState(() {
                      selectedOption1 = newValue!;
                      widget.onFilterChanged(newValue, widget.controller.action);
                    });
                  },
                  items:
                      widget.options1.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        convertSnakeCaseToTitleCase(value),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white), // White Pure
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.appPrimary.withOpacity(0.4), width: 0.6), // Fine Green Neon border
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  icon:
                      const Icon(Icons.keyboard_arrow_down, color: AppColor.appPrimary, size: 20),
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: width * 0.032,
                      color: Colors.white, // White Pure
                      fontWeight: FontWeight.bold),
                  dropdownColor: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  value: widget.controller.action,
                  onChanged: (newValue) {
                    setState(() {
                      selectedOption2 = newValue!;
                      widget.onFilterChanged(widget.controller.paid, newValue);
                    });
                  },
                  items:
                      widget.options2.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        convertSnakeCaseToTitleCase(value),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white), // White Pure
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

 String convertSnakeCaseToTitleCase(String input) {
  if (input.isEmpty) return 'Ninguno';

  if (input == 'paid') return 'Pagado';
  if (input == 'unpaid') return 'No Pagado';
  if (input == 'actions') return 'Acciones';
  if (input == 'clicks') return 'Clics';
  if (input == 'sale') return 'Venta';
  if (input == 'external_integration') return 'Integración Externa';
  if (input == 'Empty' || input == 'empty') return 'Vacío';

  List<String> words = input.split('_');
  List<String> capitalizedWords = [];

  for (String word in words) {
    String capitalizedWord = word[0].toUpperCase() + word.substring(1);
    capitalizedWords.add(capitalizedWord);
  }

  return capitalizedWords.join(' ');
}
}
