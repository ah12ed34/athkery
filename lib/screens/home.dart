import 'package:athkery/controller/home_controller.dart';
import 'package:athkery/widgets/w_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constrant.dart';
import '../models/thaker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // List<Thaker> _athker = controller.athker;
  // int? selectZ ;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: kPrimaryColor, // لون خلفية الشريط السفلي
      systemNavigationBarIconBrightness: Brightness.light, // لون الأيقونات
    ));
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("اذكاري")),
          body: SafeArea(
            child: Column(
              children: [
                Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  controller.setSelect(index);
                                },
                                child: WCategory(
                                  title: controller.categories[index].title,
                                  isSelect: controller.isSelected(index),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    )),
                Flexible(
                  flex: 5,
                  child: RefreshIndicator(
                    onRefresh: () {
                      return Future.delayed(
                        const Duration(seconds: 1),
                        () {
                          controller.getDataNew;
                        },
                      );
                    },
                    child: ListView.builder(
                      itemCount: controller.athker.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          setState(() {
                            controller.selectZ = index;
                          });
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.athker[index].thaker,
                                      overflow: TextOverflow.visible,
                                      style: const TextStyle(fontSize: 25),
                                    ),
                                  ),
                                  Text(
                                      "${controller.athker[index].size}/${controller.athker[index].count}")
                                ],
                              ),
                            ),
                            const Divider(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (controller.selectZ != null)
                  Flexible(
                    flex: 5,
                    child: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              controller.athker[controller.selectZ!].thaker
                                  .toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          Text(
                            controller.athker[controller.selectZ!].count
                                .toString(),
                            style: const TextStyle(fontSize: 25),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(35),
                            child: SizedBox(
                              width: 75,
                              height: 75,
                              child: FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    controller.athker[controller.selectZ!]
                                        .incrmet();
                                  });
                                },
                                child: const Icon(Icons.add),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
          floatingActionButton: InkWell(
            onLongPress: () {
              setState(() {
                if (controller.athker.isNotEmpty) {
                  for (var element in controller.athker) {
                    element.rest();
                  }
                }
              });
            },
            child: FloatingActionButton(
              onPressed: () {
                if (controller.athker.isNotEmpty) {
                  setState(() {
                    controller.athker[controller.selectZ!].rest();
                  });
                }
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.restart_alt),
            ),
          ),
          //InkWell(child: Vac,)
        );
      },
    );
  }
}
