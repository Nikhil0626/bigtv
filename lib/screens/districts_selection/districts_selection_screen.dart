import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../globel_keys/app_router.dart';
import '../../utils/app_colors.dart';
import '../chota_info_screens/chota_info.dart';
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "మీ జిల్లాను ఎంచుకోండి, మీ ఊర్లో తాజా ఈవెంట్లు తెలుసుకోండి!",
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            height(height: 16.0),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
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
                                  searchName:
                                      searchDistrictController.text.trim()));
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
            BlocConsumer<DistrictSelectionBloc, DistrictSelectionState>(
              builder: (context, state) {
                if (state is LoadingDistrictsState ||
                    state is SubmitLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SuccessDistrictsState) {
                  return Expanded(
                    child: Stack(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 55,
                            ),
                            child: ListView.builder(
                              itemCount: state.filterDistrictsList.length,
                              itemBuilder: (context, index) {
                                final district =
                                    state.filterDistrictsList[index];

                                final isSelected = state.selectedDistrictList
                                    .contains(district.id);

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
                                              ? AppColors.appButtonColor
                                              : AppColors.borderColor,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
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
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<DistrictSelectionBloc>()
                                    .add(SubmitDistricts());
                              },
                              child: Container(
                                height: 40,
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
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
                    ),
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
              listener: (context, state) {
                if (state is SubmitSuccessState) {
                  Navigator.pushNamed(context, RoutesManager.chotaInfo);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
