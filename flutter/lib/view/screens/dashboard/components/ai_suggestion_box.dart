import 'package:flutter/material.dart';

class AISuggestionBox extends StatelessWidget {
  final String suggestion;
  final VoidCallback? onHide;
  final VoidCallback? onHideForever;

  const AISuggestionBox({
    super.key,
    required this.suggestion,
    this.onHide,
    this.onHideForever,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.deepPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  suggestion,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          if (onHide != null && onHideForever != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onHide,
                  child: const Text("Ocultar"),
                ),
                TextButton(
                  onPressed: onHideForever,
                  child: const Text("No mostrar de nuevo"),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}