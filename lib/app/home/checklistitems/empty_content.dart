import 'package:flutter/material.dart';

/// Copyright Andrea Bozito, with modifications.
/// Notable additions and classes by Greg Lorriman as noted.

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    Key? key,
    this.title = 'Wow! Big Empty',
    this.message = 'Add a new item to get started',
  }) : super(key: key);
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SelectableText(
            title,
            style: const TextStyle(fontSize: 32.0),
          ),
          SelectableText(
            message,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
