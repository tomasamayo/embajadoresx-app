import 'package:flutter/material.dart';
import 'package:affiliatepro_mobile/model/dashboard_model.dart';

import '../../../base/expense_card.dart';

class DataCubic extends StatelessWidget {
  const DataCubic({super.key, required this.model});
  final DashboardModel model;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ExpenseCard(
          title: "Balance",
          data: model.data.userTotals.userBalance,
        ),
        ExpenseCard(
          title: "Acción",
          data:
              "${model.data.userTotals.clickActionTotal.toInt()}/${model.data.userTotals.clickActionCommission}",
        ),
        ExpenseCard(
          title: "Clics",
          data:
              "${model.data.userTotals.totalClicksCount.toInt()}/${model.data.userTotals.totalClicksCommission}",
        ),
        ExpenseCard(
          title: "Total Referido (Año)",
          data: model.data.userTotalsYear,
        ),
      ],
    );
  }
}
