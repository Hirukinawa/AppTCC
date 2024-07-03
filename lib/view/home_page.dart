import 'package:flutter/material.dart';
import 'package:uniride/widgets/auth_check.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthCheck(),
    );
  }
}
