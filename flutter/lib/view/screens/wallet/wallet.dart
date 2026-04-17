import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:affiliatepro_mobile/utils/colors.dart';
import 'package:affiliatepro_mobile/utils/text.dart';
import 'package:affiliatepro_mobile/view/screens/wallet/shimmer_widget.dart';
import 'package:affiliatepro_mobile/view/screens/wallet/walletListView.dart';
import '../../../controller/wallet_controller.dart';
import '../../base/custom_app_bar.dart';
import '../dashboard/components/menu.dart';
import 'components/wallet_data_tripplets.dart';
import 'listComponents/filter_widget.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final WalletController walletController = Get.put(WalletController());

  @override
  void initState() {
    walletController.getWalletData(1, 100);
    super.initState();
  }

  update(
    String? paidStatus,
    String? type,
  ) {
    walletController.updateActionAndPaid(paidStatus:paidStatus,type:type);
    walletController
        .getWalletData(1, 100,);
  }

  refresh() {
    walletController.updateActionAndPaid(paidStatus: '', type: '');
    walletController.getWalletData(1, 100);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return GetBuilder<WalletController>(
      builder: (WalletController) {
        if (WalletController.isLoading || WalletController.isWalletLoading) {
          return WalletShimmerWidget(
            controller: WalletController,
          );
        } else {
          var walletModel = WalletController.walletData;
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(color: Colors.white), // Este es el único ícono a la izquierda
              title: const Text("Billetera", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: false,
            ),
            drawer: const Drawer(
              child: MenuPage(),
            ),
            backgroundColor: AppColor.dashboardBgColor, // Keep base color or make transparent if needed
            body: Stack(
              children: [
                // 1. Radial Gradient Background (Top Left)
                Positioned(
                  top: -250,
                  left: -150,
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          AppColor.appPrimary.withOpacity(0.4),
                          AppColor.appPrimary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // 2. Main Content
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.05, vertical: height * 0.02),
                          child: Column(
                            children: <Widget>[
                              
                              // BIG BALANCE SECTION
                              const SizedBox(height: 10),
                              Text(
                                "SALDO TOTAL",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.appPrimary.withOpacity(0.3),
                                      blurRadius: 25,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "\$${walletModel!.data.userTotals.userBalance}",
                                  style: const TextStyle(
                                    color: AppColor.appPrimary,
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Poppins',
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: AppColor.appPrimary.withOpacity(0.5), width: 0.8), // Very fine Green Neon
                                ),
                                child: const Text(
                                  "USD Balance",
                                  style: TextStyle(
                                    color: AppColor.appPrimary, // Green Neon
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              WalletDataTripplets(
                                model: walletModel,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              // Filter Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: FilterWidget(
                                      parameter1: 'Paid Type',
                                      parameter2: 'Withdraw Type',
                                      options1: const ['','paid', 'unpaid'],
                                      options2: const [
                                        '',
                                        'actions',
                                        'clicks',
                                        'sale',
                                        'external_integration',
                                      ],
                                      onFilterChanged: update,
                                      controller: WalletController,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      refresh();
                                    },
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: AppColor.appPrimary, // Green background
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColor.appPrimary.withOpacity(0.4),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        FontAwesomeIcons.rotate,
                                        color: Colors.black, // Dark icon
                                        size: 18,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),
                              
                              // Transactions Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Historial de Comisiones",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Ver todo",
                                      style: TextStyle(
                                        color: AppColor.appPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),

                              WalletTransactionsListView(
                                controller: WalletController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
