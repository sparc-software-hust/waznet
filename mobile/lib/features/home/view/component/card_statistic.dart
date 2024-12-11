import 'package:cecr_unwomen/constants/text_constants.dart';
import 'package:cecr_unwomen/features/authentication/bloc/authentication_bloc.dart';
import 'package:cecr_unwomen/features/home/view/home_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CardStatistic extends StatelessWidget {
  const CardStatistic({super.key, required this.isHouseholdTab, required this.statistic});
  final bool isHouseholdTab;
  final Map statistic;

  @override
  Widget build(BuildContext context) {
    final String key = isHouseholdTab ? 'household' : 'scraper';
    final List householdIcons = [
      PhosphorIcons.fill.users,
      PhosphorIcons.fill.package,
      PhosphorIcons.fill.recycle,
      PhosphorIcons.fill.trashSimple,
    ];

    final List scraperIcons = [
      PhosphorIcons.fill.users,
      PhosphorIcons.fill.package,
      PhosphorIcons.fill.trashSimple,
      PhosphorIcons.fill.currencyCircleDollar,
    ];
    final int roleId = context.watch<AuthenticationBloc>().state.user!.roleId;
    final Map<String, String> keysStatistic = 
        roleId == 1 ? adminStatistic[key] ?? {}
      : roleId == 2 ? householdStatistic
      : scraperStatistic;
    
    return Container(
      margin: EdgeInsets.only(top: roleId == 1 ? 0 : 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        padding: const EdgeInsets.only(top: 0),
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        physics: const NeverScrollableScrollPhysics(),
        children: keysStatistic.entries.mapIndexed((i, e) {
          final icon = roleId == 1 ? isHouseholdTab ? householdIcons[i] : scraperIcons[i]
              : roleId == 2 ? householdIcons[i] : scraperIcons[i];

          return CardInfoWidget(
            icon: PhosphorIcon(
              icon, size: 100, color: Colors.white
            ),
            text: e.value,
            number: i == 0 && roleId != 1 ? (statistic["days_joined"] ?? 0).toString() : 
              i == 0 && roleId == 1 ? (statistic[e.key] ?? 0).toString() : (statistic[e.key] ?? 0).toStringAsFixed(2)
          );
        }).toList(),
      ),
    );
  }
}