import 'dart:io';

import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/authentication/authentication.dart';
import 'package:cecr_unwomen/features/authentication/models/user.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/user/repository/user_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChangeInfoScreen extends StatefulWidget {
  const ChangeInfoScreen({super.key});

  @override
  State<ChangeInfoScreen> createState() => _ChangeInfoScreenState();
}

class _ChangeInfoScreenState extends State<ChangeInfoScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  DateTime? birthDate;
  Gender? gender;
  final ColorConstants colorConstants = ColorConstants();
  late User user;
  late User userClone;
  FToast fToast = FToast();


  @override
  void initState() {
    super.initState();
    user = context.read<AuthenticationBloc>().state.user!;
    userClone = user.clone(user.toJson());
    firstNameController.text = userClone.firstName;
    lastNameController.text = userClone.lastName;
    phoneController.text = userClone.phoneNumber;
    addressController.text = userClone.location ?? '';
    birthDateController.text = userClone.dateOfBirth != null ? DateFormat("dd/MM/yyyy").format(userClone.dateOfBirth!) : "";
    birthDate = userClone.dateOfBirth;
    gender = userClone.gender;
    fToast.init(context);
  }

  Future<File?> getImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }
    File file = File(image.path);
    return file;
  }


  void updateInfo({required Map userResponse, isSuccess = true}) {
    if (!context.mounted) return;
    if (userResponse.isNotEmpty && isSuccess) {
      context.read<AuthenticationBloc>().add(UpdateInfo(User.fromJson(userResponse)));
      fToast.showToast(
        child: const ToastContent(
          isSuccess: true, 
          title: 'Cập nhật thành công'
        ),
        gravity: ToastGravity.BOTTOM
      );
    } else {
      fToast.showToast(
        child: const ToastContent(
          isSuccess: false, 
          title: 'Cập nhật thất bại. Vui lòng thử lại sau'
        ),
        gravity: ToastGravity.BOTTOM
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), 
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F5),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              HeaderWidget(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Row(
                    children: [
                      InkWell(
                        child: Icon(PhosphorIcons.regular.arrowLeft, size: 20, color: const Color(0xff29292A),),
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16,),
                      Text(
                        'Sửa thông tin',
                        style: colorConstants.fastStyle(16, FontWeight.w600, const Color(0xff29292A)),
                      ),
                    ],
                  ),
                ),
              ),
          
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CustomCircleAvatar(
                              size: 104,
                              avatarUrl: userClone.avatarUrl,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () async {
                                  File? pickedImg = await getImage();
                                  if (pickedImg == null) return;
                                  if (context.mounted) {
                                    Utils.showLoadingDialog(context);
                                  }
                                  UserApi.changeAvatar(
                                    data:  FormData.fromMap({
                                      "data": await MultipartFile.fromFile(pickedImg.path),
                                    }),
                                    onError: (err) {
                                      if (context.mounted) {
                                        // pop dialog loading
                                        Navigator.of(context).pop();
                                      }
                                      fToast.showToast(
                                        child: const ToastContent(
                                          isSuccess: false, 
                                          title: 'Cập nhật thất bại. Vui lòng thử lại sau'
                                        ),
                                        gravity: ToastGravity.BOTTOM
                                      );
                                    }
                                  ).then((res) {
                                    if (context.mounted) {
                                      // pop dialog loading
                                      Navigator.of(context).pop();
                                    }
                                    updateInfo(userResponse: res["data"], isSuccess: res["success"]);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Họ',
                              controller: firstNameController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Tên',
                              controller: lastNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Số điện thoại',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        label: 'Ngày sinh',
                        value: birthDate,
                        onTap: () => Utils.showDatePicker(
                          context: context,
                          onCancel: () {
                            birthDate = DateFormat("dd/MM/yyyy").parse(birthDateController.text);
                            Navigator.pop(context);
                          },
                          onSave: () {
                            birthDate = birthDate ?? DateTime.now();
                            birthDateController.text = DateFormat("dd/MM/yyyy").format(birthDate!);
                            Navigator.pop(context);
                          },
                          onDateTimeChanged: (date) {
                            birthDate = date;
                          },
                          initDate: birthDate
                        )
                      ),
                      const SizedBox(height: 16),
                      _buildGenderSelection(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Địa chỉ',
                        controller: addressController,
                        maxLines: 2,
                        hintText: addressController.text.isEmpty ? "Nhập địa chỉ" : null
                      ),
                    ],
                  ),
                ),
              ),
          
              // Update Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    userClone = userClone.copyWith(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      // phoneNumber: phoneController.text,
                      location: addressController.text,
                      gender: gender,
                      dateOfBirth: birthDate
                    );
                    Map updatedUser = await UserApi.updateInfo(userClone.toJson());
                    updateInfo(userResponse: updatedUser);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cập nhật',
                    style: colorConstants.fastStyle(16, FontWeight.w700,const Color(0xffFFFFFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: colorConstants.fastStyle(14, FontWeight.w600,const Color(0xff666667)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: colorConstants.fastStyle(16, FontWeight.w400,const Color(0xff333334)),
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hintText,
            hintStyle: colorConstants.fastStyle(14, FontWeight.w400,const Color(0xffC1C1C2)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: colorConstants.fastStyle(14, FontWeight.w600,const Color(0xff666667)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          onTap: onTap,
          style: colorConstants.fastStyle(16, FontWeight.w400,const Color(0xff333334)),
          controller: birthDateController,
          decoration: InputDecoration(
            suffixIcon: Icon(PhosphorIcons.regular.calendarBlank, size: 20, color: const Color(0xff4CAF50),),
            filled: true,
            fillColor: Colors.white,
            hintText: "Chọn ngày sinh",
            hintStyle: colorConstants.fastStyle(14, FontWeight.w400,const Color(0xffC1C1C2)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới tính',
          style: colorConstants.fastStyle(14, FontWeight.w600,const Color(0xff666667)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Nam', Gender.male),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption('Nữ', Gender.female),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderOption('Khác', Gender.other),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, Gender value) {
    final isSelected = gender == value;
    return InkWell(
      onTap: () {
        setState(() => gender = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xffC1C1C2),
              weight: 2,
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}