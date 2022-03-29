import 'package:shop/modules/login/login_screen.dart';
import 'package:shop/shared/components/components.dart';
import 'package:shop/shared/cubit/shop_cubit.dart';
import 'package:shop/shared/network/local/cash_helper.dart';

String? token;


void signOut(context) {
  CacheHelper.removeData(key: 'token').then((value) {
    if (value) {
      ShopCubit.get(context).currentIndex = 0;
      navigateAndFinish(context, LoginScreen());
    }
  });
}

