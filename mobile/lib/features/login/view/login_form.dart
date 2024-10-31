import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/login/login.dart';
import 'package:cecr_unwomen/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.fail) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Authentication Failure')),
            );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PhoneNumberInput(),
          const SizedBox(height: 15),
          _PasswordInput(),
          const SizedBox(height: 50),
          _LoginButton(),
        ],
      ),
    );
  }
}

class _PhoneNumberInput extends StatefulWidget {
  @override
  State<_PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<_PhoneNumberInput> {
  final TextEditingController _phoneController = TextEditingController();
  final ColorConstants colorConstants = ColorConstants();

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // final displayError = context.select(
    //   (LoginBloc bloc) => bloc.state.username.displayError,
    // );

    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        fillColor: colorConstants.primaryWhite1,
        border: InputBorder.none,
        hintText: "Phone number",
        hintStyle:
            TextStyle(color: colorConstants.primaryBlack1, fontWeight: FontWeight.bold, fontSize: 16),
        // contentPadding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        contentPadding: const EdgeInsets.all(20),
      ),
      onChanged: (phoneNumber) {
        context.read<LoginBloc>().add(LoginPhoneNumberChanged(phoneNumber: phoneNumber));
      },
      style: const TextStyle(
        color: Colors.black,
      ),
      validator: (value) {
        print('vaueeee:$value');
        // if (!isValidEmail(value!)) {
        //   return "Enter valid email: example@email.com";
        // }
        // if (value.isEmpty) {
        //   return "Email can't left empty";
        // }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction
    )
;  }
}

class _PasswordInput extends StatefulWidget {
  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final ColorConstants colorConstants = ColorConstants();

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final displayError = context.select(
    //   (LoginBloc bloc) => bloc.state.password.displayError,
    // );

    return TextFormField(
      obscureText: _obscureText,
      controller: _passwordController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Password",
        hintStyle:
            TextStyle(color: colorConstants.primaryBlack1, fontWeight: FontWeight.bold, fontSize: 16),
        contentPadding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black),
        ),
      ),
      style: const TextStyle(color: Colors.black),
      onChanged: (password) {
        context.read<LoginBloc>().add(LoginPasswordChanged(password: password));
      },
      validator: (value) {
        print('vaueee222e:$value');
        // if (!isValidPassword(value!)) {
        //   return "Enter valid password: at least 8 digit";
        // }
        // if (value.isEmpty) {
        //   return "Password can't left empty";
        // }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isInProgress = context.select((LoginBloc bloc) => bloc.state.status) == LoginStatus.inProcess;

    if (isInProgress) return const CircularProgressIndicator();

    final isValid = context.select((LoginBloc bloc) => bloc.state.isValid);

    return SubmitButton(
      onTap: () {
        if (!isValid) return;
        context.read<LoginBloc>().add(LoginSubmitted());
      },
      text: "Đăng nhập"
    );
  }
}