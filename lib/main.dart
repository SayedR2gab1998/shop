import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/modules/login/login_screen.dart';
import 'package:shop/shared/components/constants.dart';
import 'package:shop/shared/cubit/shop_cubit.dart';
import 'package:shop/shared/cubit/shop_states.dart';
import 'package:shop/shared/network/local/cash_helper.dart';
import 'package:shop/shared/network/remot/dio_helper.dart';
import 'package:shop/shared/styles/themes.dart';
import 'layout/shop_layout/shop_layout.dart';
import 'modules/on_boarding/on_boarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();
  late Widget home;
  bool? _onBoarding = CacheHelper.getData(key: 'onBoarding');
  token = CacheHelper.getData(key: 'token');

  if (_onBoarding != null) {
    if (token != null) {
      home = ShopLayout();
    } else {
      home = LoginScreen();
    }
  } else {
    home = const OnBoardingScreen();
  }

  DioHelper.init();

  runApp(MyApp(
    home: home,
  ));
}

class MyApp extends StatelessWidget {

  final Widget home;

  const MyApp({Key? key, required this.home})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => ShopCubit()
            ..getHomeData()
            ..getCategoriesData()
            ..getFavoritesData()
            ..getUserData(),
        ),
      ],
      child: BlocConsumer<ShopCubit, ShopStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            home: home,
          );
        },
      ),
    );
  }
}
