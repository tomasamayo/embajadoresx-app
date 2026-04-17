import 'package:flutter/material.dart';
import '../../../../../utils/colors.dart';
import '../../../../model/wallet_model.dart';
import '../components/dateConverter.dart';

class WalletCardDetail extends StatefulWidget {
  Transaction data;
  WalletCardDetail({super.key, required this.data});

  @override
  State<WalletCardDetail> createState() => _WalletCardDetailState();
}

class _WalletCardDetailState extends State<WalletCardDetail> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          children: [
            itemList(
              width,
              'Pago',
              widget.data.paymentMethod?.toString() ?? 'No Pagado',
            ),
            itemList(
              width,
              'Estado',
              widget.data.statusText,
            ),
            itemList(
              width,
              'Comisión',
              widget.data.displayAmount,
              customColor: widget.data.isIncome ? AppColor.appPrimary : Colors.redAccent,
            ),
            itemList(
              width,
              'Fecha',
              formatDate(widget.data.createdAt),
            ),
            itemList(
              width,
              'Tipo de Comisión',
              widget.data.displayTitle,
            ),
            itemList(
              width,
              'IDs de Producto',
              widget.data.referenceId,
            ),
            itemList(
              width,
              'IP',
              widget.data.domainName ?? 'N/A',
            ),
            itemList(
              width,
              'ID',
              widget.data.id,
            ),
            itemList(
              width,
              'URL',
              widget.data.pageName ?? 'N/A',
            ),
            itemList(
              width,
              'Usuario',
              '${widget.data.firstname} ${widget.data.lastname}',
            ),
          ],
        ),
      ),
    );
  }

  Widget itemList(width, text1, text2, {Color? customColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              text1,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: width * 0.035,
                  color: AppColor.appGrey,
                  fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                text2,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: width * 0.035,
                    color: customColor ?? AppColor.appWhite,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}