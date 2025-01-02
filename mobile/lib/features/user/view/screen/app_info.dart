import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppInfo extends StatelessWidget {
  final ColorConstants colorConstants = ColorConstants();
  AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Về chúng tôi',
                        style: colorConstants.fastStyle(16, FontWeight.w600, const Color(0xff29292A)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30,),
              SizedBox(
                height: 100,
                child: Image.asset("assets/icon/logo_green.png",)
              ),
              Text("WazNet", style: colorConstants.fastStyle(26, FontWeight.w900, const Color(0xff4CAF50))),
              const SizedBox(height: 20,),
              Text("Phiên bản 1.0.0", style: colorConstants.placeholderStyle()),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Một sản phẩm của ", style: colorConstants.placeholderStyle()),
                    TextSpan(text: "SPARC ", style: colorConstants.highlightPlaceHolderStyle()),
                    TextSpan(text: "và ", style: colorConstants.placeholderStyle()),
                    TextSpan(text: "CECR", style: colorConstants.highlightPlaceHolderStyle())
                  ]
                )
              ),
              const SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: NavigationButton(
                  onTap: () => Utils.showDialogWarningError(
                    context, false, "Chức năng đang được phát triển"
                  ),
                  icon: PhosphorIcons.regular.globe,
                  text: "Trang web",
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: NavigationButton(
                  onTap: () => Utils.showDialogWarningError(
                    context, false, "Chức năng đang được phát triển"
                  ),
                  icon: PhosphorIcons.regular.briefcase,
                  text: "Đối tác",
                ),
              )
          ],
        ),
      )
    );
  }
}