import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../controller/Payments_controller.dart';
import '../../../../../utils/colors.dart';

class NumberAdjuster extends StatefulWidget {
  PaymentsController paymentsController;

  NumberAdjuster({super.key, required this.paymentsController});

  @override
  _NumberAdjusterState createState() => _NumberAdjusterState();
}

class _NumberAdjusterState extends State<NumberAdjuster> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    showbottomSheet(PaymentsController PaymentsController) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1D1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.only(top: 12, bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                DialogScreen(
                  paymentsController: PaymentsController,
                ),
              ],
            ),
          );
        },
      );
    }

    return GetBuilder<PaymentsController>(builder: (PaymentsController) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                showbottomSheet(PaymentsController);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColor.appPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.tune, color: AppColor.appPrimary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pág: ${PaymentsController.pageIdd}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1,
                      height: 14,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ítems: ${PaymentsController.perPagee}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class DialogScreen extends StatefulWidget {
  PaymentsController paymentsController;

  DialogScreen({super.key, required this.paymentsController});

  @override
  State<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  late int pageId;
  late int itemsPerPage;

  @override
  void initState() {
    super.initState();

    pageId = widget.paymentsController.pageIdd;
    itemsPerPage = widget.paymentsController.perPagee;
  }

  refresh(int pageIdNew, int perPageNew) {
    Get.find<PaymentsController>()
        .updatePageIdandPerPage(pageIdNew, perPageNew);
    Get.find<PaymentsController>().getPaymentsData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Ajustes de Vista',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildAdjusterRow('Número de Página', pageId, (val) => setState(() => pageId = val), min: 0),
          const SizedBox(height: 25),
          _buildAdjusterRow('Ítems Por Página', itemsPerPage, (val) => setState(() => itemsPerPage = val), min: 1),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppColor.appPrimary,
                  AppColor.appPrimary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.appPrimary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                refresh(pageId, itemsPerPage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Aplicar Cambios',
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
        ],
      ),
    );
  }

  Widget _buildAdjusterRow(String label, int value, Function(int) onChanged, {int min = 0}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildAdjustButton(Icons.remove, () {
              if (value > min) onChanged(value - 1);
            }),
            Container(
              constraints: const BoxConstraints(minWidth: 60),
              alignment: Alignment.center,
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildAdjustButton(Icons.add, () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: AppColor.appPrimary, size: 20),
        ),
      ),
    );
  }
}
