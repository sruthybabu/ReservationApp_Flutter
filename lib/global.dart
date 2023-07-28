import 'package:flutter/material.dart';

showMessage(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Color.fromARGB(255, 233, 8, 8), content: Text(message)));
}