import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';

class TaskOverviewScreen extends StatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  State<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: NeoBrutalist.iconButton(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: NeoBrutalist.iconButton(),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: NeoBrutalist.iconButton(),
                        child: const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Task Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 18),

              // Summary Cards (In Process & Completed)
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'In Process',
                      subtitle: '12 Tasks',
                      color: AppColors.statusInProcess,
                      icon: Icons.access_time_filled_rounded,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Completed',
                      subtitle: '42 Tasks',
                      color: AppColors.statusCompleted,
                      icon: Icons.assignment_turned_in_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Chart Card 1: Daily Tasks Overview (Line Chart)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: NeoBrutalist.card(
                  borderRadius: 20,
                  borderWidth: 1.5,
                  shadowOffset: const Offset(0, 3.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily tasks overview',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Weekly',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Line Chart
                    SizedBox(
                      height: 160,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (val) => FlLine(
                              color: const Color(0xFFF0F2F5),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: 2,
                                getTitlesWidget: (val, meta) => Text(
                                  '${val.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ];
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < days.length) {
                                    return Text(
                                      days[idx],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: 8,
                          lineBarsData: [
                            // In Process Curve (Yellow)
                            LineChartBarData(
                              isCurved: true,
                              color: AppColors.statusInProcess,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              spots: const [
                                FlSpot(0, 2),
                                FlSpot(1, 4),
                                FlSpot(2, 4.2),
                                FlSpot(3, 5),
                                FlSpot(4, 4),
                                FlSpot(5, 5.5),
                                FlSpot(6, 4),
                              ],
                            ),
                            // Completed Curve (Teal)
                            LineChartBarData(
                              isCurved: true,
                              color: AppColors.statusCompleted,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              spots: const [
                                FlSpot(0, 2.8),
                                FlSpot(1, 2.2),
                                FlSpot(2, 4.5),
                                FlSpot(3, 5.8),
                                FlSpot(4, 3.8),
                                FlSpot(5, 2.5),
                                FlSpot(6, 1.8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendPill(
                          color: AppColors.statusInProcess,
                          label: 'In Process',
                        ),
                        const SizedBox(width: 16),
                        _buildLegendPill(
                          color: AppColors.statusCompleted,
                          label: 'Completed',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Chart Card 2: Project Overview (Bar Chart)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: NeoBrutalist.card(
                  borderRadius: 20,
                  borderWidth: 1.5,
                  shadowOffset: const Offset(0, 3.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project overview',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Avg project daily',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Weekly',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bar Chart
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 8,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 24,
                                interval: 2,
                                getTitlesWidget: (val, meta) => Text(
                                  '${val.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ];
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < days.length) {
                                    return Text(
                                      days[idx],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 2,
                            getDrawingHorizontalLine: (val) => FlLine(
                              color: const Color(0xFFF0F2F5),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _buildBarGroup(0, 4.0),
                            _buildBarGroup(1, 6.0),
                            _buildBarGroup(2, 4.5),
                            _buildBarGroup(3, 7.0),
                            _buildBarGroup(4, 5.0),
                            _buildBarGroup(5, 3.5),
                            _buildBarGroup(6, 5.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 9,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLegendPill({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
