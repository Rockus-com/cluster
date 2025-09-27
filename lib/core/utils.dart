// lib/core/utils.dart
import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ),
  );
}

// Other utils...