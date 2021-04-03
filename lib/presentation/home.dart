import 'package:flutter/material.dart';
import '../presentation/user_list.dart';
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: UserList()
    );
  }
}
