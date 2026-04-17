import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../model/bannerAndLinks_model.dart';
import '../../../../utils/colors.dart';
import "package:share_plus/share_plus.dart";
import 'package:qr_flutter/qr_flutter.dart';

class ImageWidget extends StatelessWidget {
  String image;
  var width;
  BannerData data;
  ImageWidget(
      {super.key,
        required this.image,
        required this.width,
        required this.data});

  Future<void> share() async {
    await Share.share(
      data.share_url,
      subject: 'Share Item',
    );
  }

  @override
  Widget build(BuildContext context) {
    showbottomSheet() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: AppColor.appPrimaryLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.appGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Código QR",
                    style: TextStyle(
                      color: AppColor.appPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Escanea este código para acceder al enlace",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.appGrey,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    ),
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: (data.share_url != null && data.share_url!.isNotEmpty)
                          ? QrImageView(
                              data: data.share_url!,
                              version: QrVersions.auto,
                              size: 180.0,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Colors.black,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Colors.black,
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_2, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text("URL no válida", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      );
    }

    return SizedBox(
      width: width / 2.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //image
            width: width / 2.2,
            height: width / 3.5,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(20.0),
              ),
            ),
            child: image != ''
                ? ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(20.0),
              ),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: image,
                httpHeaders: const {
                   'Access-Control-Allow-Origin': '*',
                }, // CORS fix attempt
                progressIndicatorBuilder:
                    (context, url, downloadProgress) => Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey[300]!),
                        value: downloadProgress.progress),
                  ),
                ),
                errorWidget: (context, url, error) {
                   debugPrint('Image load error: $error for url: $url');
                   return const Icon(Icons.image_not_supported);
                },
              ),
            )
                : Center(
              child: Icon(
                Icons.image,
                size: 10,
                color: Colors.grey[400],
              ),
            ),
          ),
          SizedBox(
            height: width * 0.04,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showbottomSheet();
                },
                child: Container(
                  height: width * 0.15,
                  width: width * 0.15,
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: AppColor.appPrimary,
                    borderRadius: BorderRadius.circular(width * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(-1, -1),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                  child: Builder(
                    builder: (context) {
                      double priceValue =
                          double.tryParse(data.price.replaceAll(',', '')) ?? 0.0;
                      double commission = priceValue * 0.3;
                      String text = priceValue > 0
                          ? "Ganas \$${commission.toStringAsFixed(2)}"
                          : "Ganas --";
                      return Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.appWhite,
                          fontFamily: 'Poppins',
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  share();
                },
                child: Container(
                  height: width * 0.15,
                  width: width * 0.15,
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: AppColor.appPrimary,
                    borderRadius: BorderRadius.circular(width * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(-1, -1),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.share_rounded, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
