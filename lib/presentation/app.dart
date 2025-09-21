import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/locator.dart';
import 'cubits/auth_cubit.dart';
import 'pages/auth/auth_screen.dart';
import 'pages/home/home_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}