import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/layout/shop_layout/shop_layout.dart';
import 'package:shop/modules/login/login_cubit/login_cubit.dart';
import 'package:shop/modules/login/login_cubit/login_states.dart';
import 'package:shop/modules/register/register_screen.dart';
import 'package:shop/shared/components/components.dart';
import 'package:shop/shared/components/constants.dart';
import 'package:shop/shared/cubit/shop_cubit.dart';
import 'package:shop/shared/network/local/cash_helper.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            if (state.model.status == true) {
              showToast(
                message: '${state.model.message}',
                state: ToastStates.SUCCESS,
              );
              CacheHelper.saveData(key: 'token', value: state.model.data!.token!)
                  .then((value) {
                token = state.model.data!.token!;
                ShopCubit.get(context).getHomeData();
                ShopCubit.get(context).getCategoriesData();
                ShopCubit.get(context).getFavoritesData();
                ShopCubit.get(context).getUserData();
                navigateAndFinish(context, ShopLayout());
              });
            } else {
              showToast(
                message: '${state.model.message}',
                state: ToastStates.ERROR,
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Image(image: AssetImage('assets/images/fullLogo.png'),
                          height: 150,
                        ),
                        Text(
                          'login now to brows our hot offer',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        defaultTextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'please enter your email address';
                            }
                          },
                          inputType: TextInputType.emailAddress,
                          label: 'Email Address',
                          prefix: Icons.email_outlined,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        defaultTextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'please enter your password';
                            }
                          },
                          onSubmit: (value) {
                            if (formKey.currentState!.validate()) {
                              LoginCubit.get(context).userLogin(
                                  email: _emailController.text,
                                  password: _passwordController.text);
                            }
                          },
                          inputType: TextInputType.visiblePassword,
                          label: 'Password',
                          prefix: Icons.lock_open_rounded,
                          isPassword: LoginCubit.get(context).isPassword,
                          suffix: LoginCubit.get(context).suffixIcon,
                          onSuffixPressed: () {
                            LoginCubit.get(context)
                                .changePasswordVisibility();
                          }
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ConditionalBuilder(
                          condition: state is! LoginLoadingState,
                          builder: (BuildContext context) => defaultButton(
                              text: 'login',
                              isUpperCase: true,
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  LoginCubit.get(context).userLogin(
                                      email: _emailController.text,
                                      password: _passwordController.text
                                  );
                                }
                              }),
                          fallback: (BuildContext context) =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have account?',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            defaultTextButton(
                              text: 'register',
                              function: () {
                                navigateTo(context, RegisterScreen());
                              }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
