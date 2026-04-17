import 'package:flutter/material.dart';

import '../../../../../model/loglist_model.dart';
import '../../../../../utils/colors.dart';

class LogsCardDetail extends StatefulWidget {
  Click data;
  LogsCardDetail({super.key, required this.data});

  @override
  State<LogsCardDetail> createState() => _LogsCardDetailState();
}

class _LogsCardDetailState extends State<LogsCardDetail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildDetailItem('URL', widget.data.baseUrl, Icons.link),
          _buildDetailItem('Navegador', widget.data.browserName, Icons.browser_updated),
          _buildDetailItem('Versión del Navegador', widget.data.browserVersion, Icons.info_outline),
          _buildDetailItem('Cadena del Sistema', widget.data.systemString, Icons.settings_ethernet),
          _buildDetailItem('Plataforma SO', widget.data.osPlatform, Icons.computer),
          _buildDetailItem('Versión SO', widget.data.osVersion, Icons.numbers),
          _buildDetailItem('Versión Corta SO', widget.data.osShortVersion, Icons.short_text),
          _buildDetailItem('Es Móvil', widget.data.isMobile == "1" ? "Sí" : "No", Icons.phone_android),
          _buildDetailItem('Arq. SO', widget.data.osArch, Icons.architecture),
          _buildDetailItem('Es Intel', widget.data.isIntel == "1" ? "Sí" : "No", Icons.memory),
          _buildDetailItem('Código de País', widget.data.countryCode, Icons.flag),
          _buildDetailItem('IP', widget.data.ip, Icons.location_on),
          _buildDetailItem('ID', widget.data.id, Icons.tag),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.appPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.appPrimary, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "N/A" : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
