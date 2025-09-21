// auth_screen.dart
class AuthScreen extends StatelessWidget {
  final AuthCubit cubit;

  const AuthScreen({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: // ... UI компоненты
          );
        },
      ),
    );
  }
}