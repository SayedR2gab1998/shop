import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/models/categories_model/categories_model.dart';
import 'package:shop/models/change_favorites_model/change_favorites_model.dart';
import 'package:shop/models/favorites_model/favorites_model.dart';
import 'package:shop/models/home_model/home_model.dart';
import 'package:shop/models/login_model/login_model.dart';
import 'package:shop/modules/categories/categories_screen.dart';
import 'package:shop/modules/favorites/favorites_screen.dart';
import 'package:shop/modules/products/products_screen.dart';
import 'package:shop/modules/settings/settings_screen.dart';
import 'package:shop/shared/components/constants.dart';
import 'package:shop/shared/cubit/shop_states.dart';
import 'package:shop/shared/network/end_points.dart';
import 'package:shop/shared/network/remot/dio_helper.dart';

class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());

  static ShopCubit get(BuildContext context) => BlocProvider.of(context);


  int currentIndex = 0;

  List<Widget> bottomsScreens = [
    const ProductsScreen(),
    const CategoriesScreen(),
    const FavoritesScreen(),
    SettingsScreen(),
  ];

  void changeBottomNav(index) {
    currentIndex = index;
    emit(ShopChangeBottomNavState());
  }

  HomeModel? homeModel;
  Map<int, bool> inFavorites = {};

  void getHomeData() {
    if (token != null) {
      emit(ShopLoadingHomeDataState());
      DioHelper.getData(
        url: HOME,
        token: token!,
      ).then((value) {
        homeModel = HomeModel.fromJson(value.data);
        homeModel!.data.products.forEach((element) {
          inFavorites.addAll({element.id: element.inFavorites});
        });
        emit(ShopSuccessHomeDataState());
      }).catchError((error) {
        emit(ShopErrorHomeDataState(error.toString()));
        print(error.toString());
      });
    }
  }

  ChangeFavoritesModel? changeFavoritesModel;
  void changeFavorites(int productId) {
    if (token != null) {
      inFavorites[productId] = !inFavorites[productId]!;
      emit(ShopChangeFavoritesState());
      DioHelper.postData(
        url: FAVORITES,
        data: {'product_id': productId},
        token: token!,
      ).then((value) {
        changeFavoritesModel = ChangeFavoritesModel.fromJson(value.data);
        print(value.data);
        if (!changeFavoritesModel!.status) {
          inFavorites[productId] = !inFavorites[productId]!;
        } else {
          getFavoritesData();
        }
        emit(ShopSuccessChangeFavoritesState(changeFavoritesModel!));
      }).catchError((error) {
        inFavorites[productId] = !inFavorites[productId]!;
        emit(ShopErrorChangeFavoritesState(error.toString()));
        print(error.toString());
      });
    }
  }

  CategoriesModel? categoriesModel;

  void getCategoriesData() {
    if (token != null) {
      emit(ShopLoadingCategoriesState());
      DioHelper.getData(url: GET_CATEGORIES, token: token!).then((value) {
        categoriesModel = CategoriesModel.fromJson(value.data);
        emit(ShopSuccessCategoriesState());
      }).catchError((error) {
        print(error.toString());
        emit(ShopErrorCategoriesState(error.toString()));
      });
    }
  }


  FavoritesModel? getFavoritesModel;
  void getFavoritesData() {
    if (token != null) {
      emit(ShopLoadingGetFavoritesState());

      DioHelper.getData(url: FAVORITES, token: token!).then((value) {
        getFavoritesModel = FavoritesModel.fromJson(value.data);
        emit(ShopSuccessGetFavoritesState());
      }).catchError((error) {
        print(error.toString());
        emit(ShopErrorGetFavoritesState(error.toString()));
      });
    }
  }


  LoginModel? userDataModel;

  void getUserData() {
    if (token != null) {
      emit(ShopLoadingGetUserDataState());
      DioHelper.getData(url: GET_PROFILE, token: token!).then((value) {
        userDataModel = LoginModel.fromJson(value.data);
        emit(ShopSuccessGetUserDataState(userDataModel!));
      }).catchError((error) {
        print(error.toString());
        emit(ShopErrorGetUserDataState(error.toString()));
      });
    }
  }

  void updateUserData({
    required String name,
    required String email,
    required String phone,
  }) {
    if (token != null) {
      emit(ShopLoadingUpdateUserDataState());

      DioHelper.putData(
              url: UPDATE_PROFILE,
              data: {
                'name': name,
                'email': email,
                'phone': phone,
              },
              token: token!)
          .then((value) {
        userDataModel = LoginModel.fromJson(value.data);
        emit(ShopSuccessUpdateUserDataState(userDataModel!));
      }).catchError((error) {
        print(error.toString());
        emit(ShopErrorUpdateUserDataState(error.toString()));
      });
    }
  }
}
