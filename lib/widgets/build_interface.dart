import 'package:flutter/cupertino.dart';

class BuildInterface extends StatelessWidget {
  final List<Widget> children;
  final bool isLoading;

  const BuildInterface({super.key,
    required this.children,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}