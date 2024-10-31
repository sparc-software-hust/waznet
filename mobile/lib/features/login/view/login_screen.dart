import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/login/bloc/login_bloc.dart';
import 'package:cecr_unwomen/features/login/view/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorConstants colorConstants = ColorConstants();

    return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: Colors.white,
    body: SafeArea(
      child: BlocProvider(
        create: (context) => LoginBloc(),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                // welcome
                Text("Welcome to CECR_UNWomen!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: colorConstants.primaryBlack1)),
                // 2 input
                const SizedBox(height: 80),
                const LoginForm(),
                // forgot password
                const SizedBox(height: 15),
                // Container(
                //   margin: paddingLoginHorizontal30,
                //   alignment: Alignment.centerRight,
                //   child: Text(
                //     "Forgot password?",
                //     style: TextStyle(color: colorConstants.primaryBlack1, fontWeight: FontWeight.bold),
                //   ),
                // ),
                        
                // button login
                const SizedBox(height: 50),
                
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text(
                //       "Don't have an account?",
                //       style: TextStyle(color: Colors.black),
                //     ),
                //     // TextButton(
                //     //   onPressed: () => Navigator.push(
                //     //       context,
                //     //       MaterialPageRoute(
                //     //           builder: (context) => const RegisterScreen())),
                //     //   child: Text(
                //     //     "  Sign up",
                //     //     style: TextStyle(
                //     //         color: ColorConstant.primary,
                //     //         fontWeight: FontWeight.bold),
                //     //   ),
                //     // )
                //   ],
                // )
              ]),
            ),
          )
        ),
      ),
    ),
        );
  }
}
