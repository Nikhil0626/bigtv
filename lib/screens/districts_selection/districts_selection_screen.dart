import 'dart:developer';

import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../globel_keys/app_router.dart';
import '../../utils/app_colors.dart';
import 'district_selection_bloc.dart';
import 'district_selection_event.dart';
import 'district_selection_state.dart';

class DistrictsSelectionScreen extends StatefulWidget {
  final String className;

  const DistrictsSelectionScreen({super.key, required this.className});

  @override
  State<DistrictsSelectionScreen> createState() =>
      _DistrictsSelectionScreenState();
}

class _DistrictsSelectionScreenState extends State<DistrictsSelectionScreen> {
  TextEditingController searchDistrictController = TextEditingController();

  @override
  void initState() {
    context.read<DistrictSelectionBloc>().add(GetAllDistricts());
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: AppColors.appButtonColor,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                        color: AppColors.appButtonColor,
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        if (widget.className == "Home")
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              color: Colors.white,
                              Icons.arrow_back_ios,
                              size: 18,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            "మీ ప్రాంతాన్ని ఎంచుకోండి, ప్రతిరోజు మీ ఊరిలో ఏం జరుగుతుందో తెలుసుకోండి.",
                            maxLines: 3,
                            style: fontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                height(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 2.0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1, // Thin border
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Icon(
                            Icons.search,
                            color: AppColors.bodyTextColor,
                          ),
                        ),
                        width(width: 10),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.start,
                            controller: searchDistrictController,
                            decoration: InputDecoration(
                              hintText: "Search...",
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                              hintStyle: fontStyle(
                                  fontSize: 14, color: AppColors.bodyTextColor),
                              border: InputBorder.none,
                            ),
                            style: fontStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: AppColors.headerTextColor),
                            onChanged: (value) {
                              print(value.toString());
                              context.read<DistrictSelectionBloc>().add(
                                  SearchDistricts(
                                      searchName: searchDistrictController.text
                                          .trim()));
                            },
                          ),
                        ),
                        width(width: 10),
                        // if(homeProvider.homeSearchController.text.length>0)
                        IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            searchDistrictController.clear();
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            size: 20,
                            color: AppColors.bodyTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: BlocConsumer<DistrictSelectionBloc,
                      DistrictSelectionState>(
                    builder: (context, state) {
                      if (state is LoadingDistrictsState ||
                          state is SubmitLoadingState) {
                        return const Center(child: AppLoadingScreen());
                      } else if (state is SuccessDistrictsState) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 55,
                              ),
                              child: ListView.builder(
                                itemCount: state.filterDistrictsList.length,
                                itemBuilder: (context, index) {
                                  final district =
                                      state.filterDistrictsList[index];

                                  final isSelected = state.selectedDistrictList
                                      .contains(district.id.toString());

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 20.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .read<DistrictSelectionBloc>()
                                            .add(
                                              SelectedDistrictsUpdate(
                                                  selectedDistrict:
                                                      district.id.toString()),
                                            );
                                      },
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 40,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                district.name,
                                                style: fontStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Icon(
                                                isSelected
                                                    ? Icons.check_circle
                                                    : Icons
                                                        .check_circle_outline,
                                                color: Colors.lightBlue,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: InkWell(
                                  onTap: () {
                                    if (state.selectedDistrictList.length < 2) {
                                      CustomToast.showErrorToast(
                                          msg: "Select at least two districts");
                                    } else {
                                      log("Class Name  ${widget.className}");
                                      context.read<DistrictSelectionBloc>().add(
                                          SubmitDistricts(
                                              className: widget.className,
                                              context: context));
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    decoration: BoxDecoration(
                                      color:
                                          state.selectedDistrictList.length < 2
                                              ? Colors.grey
                                              : Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Done',
                                      style: fontStyle(
                                        color: Colors.white, // White text
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      } else if (state is ErrorDistrictsState) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 210),
                            child: InkWell(
                              onTap: () {
                                context.read<DistrictSelectionBloc>().add(GetAllDistricts());
                              },
                              child: Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.lightBlue,
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.refresh, color: Colors.white, size: 20),
                                      width(width: 5),
                                      Text(
                                        "Retry",
                                        style: fontStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );



                      } else {
                        return const Center(
                            // child: Navigator.pushNamed(context, routeName),
                            );
                      }
                    },
                    listener: (context, state) {
                      if (state is SubmitSuccessState) {
                        if (state.className == "Home") {
                          Navigator.pushNamed(context, RoutesManager.homeScreen,
                              arguments: {"postId": "", "tab": "1"});
                        } else {
                          Navigator.pushNamed(context, RoutesManager.homeScreen,
                              arguments: {"postId": "", "tab": "0"});
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
