import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({Key? key, this.message = 'Chargement...'})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
