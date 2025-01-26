import 'dart:math';

import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/app_colors.dart';
import 'district_selection_bloc.dart';
import 'district_selection_event.dart';
import 'district_selection_state.dart';

class DistrictsSelectionScreen extends StatefulWidget {
  const DistrictsSelectionScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,




      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              color: Colors.blueGrey,
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "మీ ప్రంతాన్ని ఎంచుకోండి, ప్రతి రోజు మీ ఊర్లో ఏమి జరుగుతుందో తెలుసుకోండి.",
                maxLines: 2,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
           height(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 15.0, vertical: 2),
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
                    // Subtle shadow for depth
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Icon(
                      Icons.search,
                      color: AppColors
                          .bodyTextColor, // Soft icon color
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
                            fontSize: 14,
                            color: AppColors
                                .bodyTextColor // Subtle hint text color
                        ),
                        border:
                        InputBorder.none, // Removes the border
                      ),
                      style: fontStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.headerTextColor),
                      onChanged: (value) {
                        print(value.toString());
                       context.read<DistrictSelectionBloc>().add(SearchDistricts(searchName: searchDistrictController.text.trim()) );
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

          BlocBuilder<DistrictSelectionBloc, DistrictSelectionState>(
            builder: (context, state) {
              if (state is LoadingDistrictsState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SuccessDistrictsState) {
                return Stack(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.filterDistrictsList.length,
                        itemBuilder: (context, index) {
                          final district = state.filterDistrictsList[index];


                          final isSelected =
                          state.selectedDistrictList.contains(district.id);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20.0),
                            child: GestureDetector(
                              onTap: () {

                                context.read<DistrictSelectionBloc>().add(
                                  SelectedDistrictsUpdate(
                                      selectedDistrict: district.id),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.lightBlue.shade500
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        district.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.check_circle_outline,
                                        color: Colors.lightBlue,
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
                    InkWell(
                      onTap: (){
                        },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        // decoration: ,
                      ),
                    )
                  ],
                );
              } else if (state is ErrorDistrictsState) {
                return const Center(
                  child: Text(
                    "Please try again later.",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    "No data available",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
