import 'package:cecr_unwomen/constants/color_constants.dart';
import 'package:cecr_unwomen/features/home/view/component/header_widget.dart';
import 'package:cecr_unwomen/features/home/view/component/toast_content.dart';
import 'package:cecr_unwomen/features/home/view/contribution_screen.dart';
import 'package:cecr_unwomen/temp_api.dart';
import 'package:cecr_unwomen/utils.dart';
import 'package:cecr_unwomen/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserContributionDetailScreen extends StatefulWidget {
  const UserContributionDetailScreen({super.key, required this.oneDayData, required this.name, this.avatarUrl, required this.date, this.roleIdUser = 2, required this.userId});
  final Map oneDayData;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String date;
  final int roleIdUser;

  @override
  State<UserContributionDetailScreen> createState() => _UserContributionDetailScreenState();
}

class _UserContributionDetailScreenState extends State<UserContributionDetailScreen> {
  final ColorConstants colorCons = ColorConstants();
  Map detailContribution = {};
  bool isLoading = false;
  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    callApiGetDetailContribution();
  }

  callApiGetDetailContribution() async {
    setState(() => isLoading = true);
    final String dateFormatted = Utils.parseContributionDate(widget.oneDayData["date"], format: "yyyy-MM-dd");
    final Map data = {
      "date": dateFormatted,
      "user_id": widget.userId,
      "role_id": widget.roleIdUser
    };
    final res = await TempApi.getDetailContribution(data);
    if (!(res["success"] ?? false)) {
      fToast.showToast(
        child: ToastContent(
          isSuccess: false, 
          title: 'Lấy dữ liệu thất bại. ${res["message"]}'
        ),
        gravity: ToastGravity.BOTTOM
      );
    } else {
      setState(() {
        detailContribution = res["data"];
      });
    }
    // await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);
  }

  _buildRowItem({required String text, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF808082)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF333334),
            fontSize: 16,
            fontWeight: FontWeight.w500
          )),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userType = widget.roleIdUser == 2 ? "Hộ gia đình" : "Người thu gom";
    return Column(
      children: [
        HeaderWidget(child:
          Container(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(PhosphorIcons.regular.arrowLeft, size: 24, color: const Color(0xFF29292A))),
              const SizedBox(width: 10),
              Text("Chi tiết", style: colorCons.fastStyle(18, FontWeight.w600, const Color(0xFF29292A))),
            ],
            ),
          )
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: isLoading ? const Center(child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)))) :
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: CustomCircleAvatar(
                      size: 88,
                      avatarUrl: widget.avatarUrl,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRowItem(text: "${widget.name} - $userType", icon: PhosphorIcons.regular.user),
                        _buildRowItem(text: widget.date, icon: PhosphorIcons.regular.clock),
                      ],
                    )
                  ),
                  if (widget.roleIdUser == 2 && detailContribution.isNotEmpty)
                  Column(
                    children: [
                      ...detailContribution.keys.map((date) {
                        return DetailContributionTypeGroup(
                          detailContribution: detailContribution[date].take(4).toList(), 
                          textHeader: "Từ chối sử dụng đồ nhựa", 
                          roleId: widget.roleIdUser, 
                          insertedAt: Utils.parseContributionDate(date)
                        );
                      }),
                      Container(
                        width: double.maxFinite,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: CountTotalOverallCo2e(
                          text: "Tổng lượng giảm phát thải khí nhà kính từ việc hạn chế đồ nhựa",
                          total: widget.oneDayData["kg_co2e_plastic_reduced"].toStringAsFixed(2),
                          icon: PhosphorIcons.fill.trashSimple,
                        ),
                      ),

                      const SizedBox(height: 16),
                      ...detailContribution.keys.map((date) {
                        return DetailContributionTypeGroup(
                          detailContribution: detailContribution[date].skip(4).toList(), 
                          textHeader: "Tái chế rác thải", 
                          roleId: widget.roleIdUser, 
                          insertedAt: Utils.parseContributionDate(date)
                        );
                      }),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: CountTotalOverallCo2e(
                          text: "Tổng lượng giảm phát thải khí nhà kính từ việc tái chế",
                          total: widget.oneDayData["kg_co2e_recycle_reduced"].toStringAsFixed(2),
                          icon: PhosphorIcons.fill.recycle,
                        ),
                      ),
                    ],
                  )
                  else if (widget.roleIdUser == 3 && detailContribution.isNotEmpty)
                  Column(
                    children: [
                      ...detailContribution.keys.map((date) {
                        return DetailContributionTypeGroup(
                          detailContribution: detailContribution[date], 
                          textHeader: "Thu gom rác thải", roleId: widget.roleIdUser, 
                          insertedAt: Utils.parseContributionDate(date)
                        );
                      }),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: CountTotalOverallCo2e(
                          text: "Tổng lượng giảm phát thải khí nhà kính từ việc thu gom",
                          total: widget.oneDayData["kg_co2e_reduced"].toStringAsFixed(2),
                          icon: PhosphorIcons.fill.recycle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: CountTotalOverallCo2e(
                          text: "Tổng số rác tái chế đã thu gom được",
                          unit: "kg",
                          total: widget.oneDayData["kg_collected"].toStringAsFixed(2),
                          icon: PhosphorIcons.fill.trash,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: CountTotalOverallCo2e(
                          text: "Trung bình chi phí xử lý rác thải tiết kiệm được nhờ đóng góp",
                          total: widget.oneDayData["expense_reduced"].toStringAsFixed(2),
                          unit: "VND",
                          icon: PhosphorIcons.fill.currencyCircleDollar,
                        ),
                      ),
                    ],
                  )
                ]
              )
            ),
          ),
        ),
      ],
    );
  }
}