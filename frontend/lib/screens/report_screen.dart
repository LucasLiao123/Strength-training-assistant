import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadWeeklyReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ReportProvider>(
          builder: (context, provider, _) {
            final report = provider.weeklyReport;
            return ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const GradientHeader(
                  title: '训练报告',
                  subtitle: '复刻附件应用的数据概览页节奏，展示完成率、力量趋势和部位覆盖度。',
                  trailing: Icon(Icons.query_stats, size: 42, color: Colors.white),
                ),
                if (provider.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (report == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('暂无报告数据'),
                  )
                else ...[
                  SectionCard(
                    title: '本周概览',
                    subtitle: '训练中提示、周报和推荐卡片都聚焦个人训练数据，不含教练端管理模块。',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _metric('完成率', '${(report.completionRate * 100).toStringAsFixed(0)}%'),
                        _metric('平均完成度', report.avgCompletionScore.toStringAsFixed(1)),
                        _metric('平均疲劳度', report.avgFatigueScore.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                  SectionCard(
                    title: '部位覆盖度',
                    subtitle: '可扩展为更完整的数据可视化面板。',
                    child: SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final muscles = report.muscleDistribution.keys.toList();
                                  final index = value.toInt();
                                  if (index < 0 || index >= muscles.length) return const SizedBox.shrink();
                                  return Text(muscles[index], style: const TextStyle(fontSize: 12));
                                },
                              ),
                            ),
                          ),
                          barGroups: report.muscleDistribution.entries.toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: item.value.toDouble(),
                                  color: AppTheme.muscleColors[item.key] ?? AppTheme.primaryColor,
                                  width: 22,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SectionCard(
                    title: '智能推荐',
                    subtitle: '后续可扩展社交分享与长期趋势分析。',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.surfaceColor, AppTheme.cardColor.withOpacity(0.9)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('你近 3 周胸部训练占比较高，建议下周为背部增加 1 个复合动作并降低胸部孤立动作量。'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }
}
