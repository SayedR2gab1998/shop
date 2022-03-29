import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/layout/shop_layout/shop_layout.dart';
import 'package:shop/modules/register/register_cubit/register_cubit.dart';
import 'package:shop/modules/register/register_cubit/register_states.dart';
import 'package:shop/shared/components/components.dart';
import 'package:shop/shared/components/constants.dart';
import 'package:shop/shared/cubit/shop_cubit.dart';
import 'package:shop/shared/network/local/cash_helper.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          if (state is RegisterSuccessState) {
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
          var cubit = RegisterCubit.get(context);
          return Scaffold(
            appBar: AppBar(),
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
                          'Register now to brows our hot offer',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        defaultTextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'please enter your name';
                              }
                            },
                            inputType: TextInputType.text,
                            label: 'User Name',
                            prefix: Icons.person,
                            textCapitalization: TextCapitalization.sentences),
                        const SizedBox(
                          height: 15,
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
                          controller: _phoneController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'please enter your phone number';
                            }
                          },
                          inputType: TextInputType.phone,
                          label: 'Phone Number',
                          prefix: Icons.phone,
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
                            inputType: TextInputType.visiblePassword,
                            label: 'Password',
                            prefix: Icons.lock_open_rounded,
                            isPassword: cubit.isPassword,
                            suffix: cubit.suffixIcon,
                            onSuffixPressed: () {
                              cubit.changePasswordVisibility();
                            }),
                        const SizedBox(
                          height: 15,
                        ),
                        defaultTextFormField(
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'please confirm your password';
                              } else if (value != _passwordController.text) {
                                return 'Password not match';
                              }
                            },
                            onSubmit: (value) {
                              if (formKey.currentState!.validate()) {
                                cubit.userRegister(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    phone: _phoneController.text,
                                    password: _passwordController.text);
                                navigateAndFinish(context,ShopLayout());
                              }
                            },
                            inputType: TextInputType.visiblePassword,
                            label: 'Confirm Password',
                            prefix: Icons.lock_open_rounded,
                            isPassword: cubit.isPassword,
                            suffix: cubit.suffixIcon,
                            onSuffixPressed: () {
                              cubit.changePasswordVisibility();
                            }),
                        const SizedBox(
                          height: 30,
                        ),
                        ConditionalBuilder(
                          condition: state is! RegisterLoadingState,
                          builder: (BuildContext context) => defaultButton(
                              text: 'register',
                              isUpperCase: true,
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  cubit.userRegister(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      phone: _phoneController.text,
                                      password: _passwordController.text);
                                  navigateAndFinish(context,ShopLayout());
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
                            const Text('Already have an account?',
                              style: TextStyle(
                                fontSize: 18
                              ),
                            ),
                            defaultTextButton(
                                text: 'Login',
                                function: () {
                                  Navigator.pop(context);
                                }),
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
