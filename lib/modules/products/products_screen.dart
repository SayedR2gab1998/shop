import 'package:carousel_slider/carousel_slider.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/models/categories_model/categories_model.dart';
import 'package:shop/models/home_model/home_model.dart';
import 'package:shop/shared/components/components.dart';
import 'package:shop/shared/cubit/shop_cubit.dart';
import 'package:shop/shared/cubit/shop_states.dart';
import 'package:shop/shared/styles/colors.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {
        if (state is ShopSuccessChangeFavoritesState) {
          if (!state.model.status) {
            showToast(message: state.model.message, state: ToastStates.ERROR);
          }
        }
      },
      builder: (context, state) {
        return ConditionalBuilder(
            condition: ShopCubit.get(context).homeModel != null &&
                ShopCubit.get(context).categoriesModel != null,
            builder: (context) => productsBuilder(
                context,
                ShopCubit.get(context).homeModel!,
                ShopCubit.get(context).categoriesModel!),
            fallback: (context) =>
                const Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget productsBuilder(
          context, HomeModel homeModel, CategoriesModel categoriesModel) =>
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              items: homeModel.data.banners
                  .map((e) => Image(
                        image: NetworkImage(
                          e.image,
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ))
                  .toList(),
              options: CarouselOptions(
                height: 250,
                initialPage: 0,
                scrollDirection: Axis.horizontal,
                autoPlay: true,
                reverse: false,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(seconds: 1),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categories',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return buildCategoryItem(
                              categoriesModel.data!.data[index]);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            width: 10,
                          );
                        },
                        scrollDirection: Axis.horizontal,
                        itemCount: categoriesModel.data!.data.length),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('New Products',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.grey.shade300,
              child: GridView.count(
                childAspectRatio: 1 / 1.55,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                children: List.generate(
                  homeModel.data.products.length,
                  (index) =>
                      buildGridProduct(context, homeModel.data.products[index]),
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildGridProduct(context, ProductModel model) => Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Image(
                  image: NetworkImage(model.image),
                  width: double.infinity,
                  height: 200,
                ),
                if (model.discount != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.red,
                    child: const Text(
                      'DISCOUNT',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Text(
                        model.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${model.price.round()}',
                          style: TextStyle(fontSize: 17, color: defaultColor),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        if (model.discount != 0)
                          Text(
                            '${model.oldPrice.round()}',
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough),
                          ),
                        const Spacer(),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          icon: CircleAvatar(
                              backgroundColor:
                                  ShopCubit.get(context).inFavorites[model.id]!
                                      ? defaultColor
                                      : Colors.grey,
                              radius: 15,
                              child: const Icon(
                                Icons.favorite_outline,
                                color: Colors.white,
                                size: 15,
                              )),
                          onPressed: () {
                            ShopCubit.get(context).changeFavorites(model.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
            ),
          ],
        ),
      );

  Widget buildCategoryItem(CategoryData model) => Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Image(
            image: NetworkImage('${model.image}'),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(.8),
            width: 100,
            child: Text(model.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17
                )),
          ),
        ],
      );
}
