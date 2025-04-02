import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../scan_provider.dart';

class SpotsChart extends StatefulWidget {
  final List<ScanModel> scans;
  final Function(ScanModel)? onScanSelected;
  final String? title;

  const SpotsChart({
    super.key,
    required this.scans,
    this.onScanSelected,
    this.title,
  });

  @override
  State<SpotsChart> createState() => _SpotsChartState();
}

enum TimeRange {
  week,
  month,
  threeMonths,
  sixMonths,
  year,
  all,
}

enum ChartView {
  bar,
  line,
  area,
}

class _SpotsChartState extends State<SpotsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedIndex;
  ChartView _currentView = ChartView.bar;
  TimeRange _timeRange = TimeRange.all;
  List<ScanModel> _filteredScans = [];
  bool _showAverageLine = false;
  double _averageValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
    _updateFilteredScans();
    _calculateAverage();
  }

  @override
  void didUpdateWidget(SpotsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scans != oldWidget.scans ||
        widget.scans.length != _filteredScans.length) {
      _updateFilteredScans();
      _calculateAverage();
    }
  }

  void _calculateAverage() {
    if (_filteredScans.isEmpty) {
      _averageValue = 0;
      return;
    }
    final total = _filteredScans.fold(
        0, (previousValue, scan) => previousValue + scan.spots);
    _averageValue = total / _filteredScans.length;
  }

  void _updateFilteredScans() {
    // Sort scans by date (oldest first)
    final sortedScans = List<ScanModel>.from(widget.scans)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final now = DateTime.now();
    final filteredScans = sortedScans.where((scan) {
      switch (_timeRange) {
        case TimeRange.week:
          return now.difference(scan.createdAt).inDays <= 7;
        case TimeRange.month:
          return now.difference(scan.createdAt).inDays <= 30;
        case TimeRange.threeMonths:
          return now.difference(scan.createdAt).inDays <= 90;
        case TimeRange.sixMonths:
          return now.difference(scan.createdAt).inDays <= 180;
        case TimeRange.year:
          return now.difference(scan.createdAt).inDays <= 365;
        case TimeRange.all:
          return true;
      }
    }).toList();

    setState(() {
      _filteredScans = filteredScans;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ?? 'Spots History',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  _buildChartTypeToggle(),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      if (_filteredScans.isEmpty) {
                        return Center(
                          child: Text(
                            'No data available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        );
                      }
                      return _buildCurrentChart();
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentChart() {
    switch (_currentView) {
      case ChartView.bar:
        return _buildBarChart();
      case ChartView.line:
        return _buildLineChart();
      case ChartView.area:
        return _buildAreaChart();
    }
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(_filteredScans) * 1.2 * _animation.value,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            //tooltipBgColor: Theme.of(context).cardColor,
            tooltipPadding: const EdgeInsets.all(12),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final scan = _filteredScans[group.x.toInt()];
              return BarTooltipItem(
                '${_formatDateLong(scan.createdAt)}\n${scan.spots} spots',
                TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          touchCallback: (event, response) {
            if (response == null || response.spot == null) {
              setState(() {
                _touchedIndex = null;
              });
              return;
            }

            if (event is FlTapUpEvent) {
              final spotIndex = response.spot!.touchedBarGroupIndex;
              setState(() {
                _touchedIndex = spotIndex;
              });
              if (widget.onScanSelected != null) {
                widget.onScanSelected!(_filteredScans[spotIndex]);
              }
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: _filteredScans.length > 10 ? 24 : 32,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _filteredScans.length) {
                  return const Text('');
                }

                // For many data points, show only every nth label
                if (_filteredScans.length > 10 && value.toInt() % 2 != 0) {
                  return const Text('');
                }

                if (_filteredScans.length > 20 && value.toInt() % 3 != 0) {
                  return const Text('');
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Transform.rotate(
                    angle: -45 * (pi / 180),
                    child: Text(
                      _formatDateShort(_filteredScans[value.toInt()].createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == meta.min) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                );
              },
              reservedSize: 28,
              interval: _calculateInterval(_filteredScans),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(_filteredScans),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        barGroups: _filteredScans.asMap().entries.map((entry) {
          final index = entry.key;
          final scan = entry.value;
          final barWidth = _filteredScans.length > 15
              ? max(6, min(12, 100 / _filteredScans.length))
              : _filteredScans.length > 8
                  ? max(10, min(18, 100 / _filteredScans.length))
                  : max(14, min(24, 100 / _filteredScans.length));

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: scan.spots.toDouble() * _animation.value,
                gradient: LinearGradient(
                  colors: _getBarGradient(scan.spots),
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: barWidth.toDouble(),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _calculateMaxY(_filteredScans) * 1.2,
                  color: Theme.of(context).dividerColor.withOpacity(0.05),
                ),
              ),
            ],
          );
        }).toList(),
        extraLinesData: _showAverageLine
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: _averageValue * _animation.value,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      labelResolver: (line) =>
                          'Avg: ${_averageValue.toStringAsFixed(1)}',
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_filteredScans.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxY(_filteredScans) * 1.2 * _animation.value,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            //tooltipBgColor: Theme.of(context).cardColor,
            tooltipPadding: const EdgeInsets.all(12),
            tooltipMargin: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final scan = _filteredScans[spot.x.toInt()];
                return LineTooltipItem(
                  '${_formatDateLong(scan.createdAt)}\n${scan.spots} spots',
                  TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            if (response == null ||
                response.lineBarSpots == null ||
                response.lineBarSpots!.isEmpty) {
              setState(() {
                _touchedIndex = null;
              });
              return;
            }

            if (event is FlTapUpEvent) {
              final spotIndex = response.lineBarSpots!.first.x.toInt();
              setState(() {
                _touchedIndex = spotIndex;
              });
              if (widget.onScanSelected != null) {
                widget.onScanSelected!(_filteredScans[spotIndex]);
              }
            }
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: _filteredScans.length > 10 ? 24 : 32,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _filteredScans.length) {
                  return const Text('');
                }

                // For many data points, show only every nth label
                if (_filteredScans.length > 10 && value.toInt() % 2 != 0) {
                  return const Text('');
                }

                if (_filteredScans.length > 20 && value.toInt() % 3 != 0) {
                  return const Text('');
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Transform.rotate(
                    angle: -45 * (pi / 180),
                    child: Text(
                      _formatDateShort(_filteredScans[value.toInt()].createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == meta.min) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                );
              },
              reservedSize: 28,
              interval: _calculateInterval(_filteredScans),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(_filteredScans),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _filteredScans.asMap().entries.map((entry) {
              final index = entry.key;
              final scan = entry.value;
              return FlSpot(
                  index.toDouble(), scan.spots.toDouble() * _animation.value);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isTouched = index == _touchedIndex;
                final color = _getSpotColor(_filteredScans[index].spots);

                return FlDotCirclePainter(
                  radius: isTouched ? 6 : 4,
                  color: color,
                  strokeWidth: isTouched ? 2 : 0,
                  strokeColor: Theme.of(context).cardColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
        extraLinesData: _showAverageLine
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: _averageValue * _animation.value,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      labelResolver: (line) =>
                          'Avg: ${_averageValue.toStringAsFixed(1)}',
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildAreaChart() {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_filteredScans.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxY(_filteredScans) * 1.2 * _animation.value,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            //tooltipBgColor: Theme.of(context).cardColor,
            tooltipPadding: const EdgeInsets.all(12),
            tooltipMargin: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final scan = _filteredScans[spot.x.toInt()];
                return LineTooltipItem(
                  '${_formatDateLong(scan.createdAt)}\n${scan.spots} spots',
                  TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                );
              }).toList();
            },
          ),
          touchCallback: (event, response) {
            if (response == null ||
                response.lineBarSpots == null ||
                response.lineBarSpots!.isEmpty) {
              setState(() {
                _touchedIndex = null;
              });
              return;
            }

            if (event is FlTapUpEvent) {
              final spotIndex = response.lineBarSpots!.first.x.toInt();
              setState(() {
                _touchedIndex = spotIndex;
              });
              if (widget.onScanSelected != null) {
                widget.onScanSelected!(_filteredScans[spotIndex]);
              }
            }
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: _filteredScans.length > 10 ? 24 : 32,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _filteredScans.length) {
                  return const Text('');
                }

                // For many data points, show only every nth label
                if (_filteredScans.length > 10 && value.toInt() % 2 != 0) {
                  return const Text('');
                }

                if (_filteredScans.length > 20 && value.toInt() % 3 != 0) {
                  return const Text('');
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Transform.rotate(
                    angle: -45 * (pi / 180),
                    child: Text(
                      _formatDateShort(_filteredScans[value.toInt()].createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == meta.min) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                );
              },
              reservedSize: 28,
              interval: _calculateInterval(_filteredScans),
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(_filteredScans),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _filteredScans.asMap().entries.map((entry) {
              final index = entry.key;
              final scan = entry.value;
              return FlSpot(
                  index.toDouble(), scan.spots.toDouble() * _animation.value);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isTouched = index == _touchedIndex;
                final color = _getSpotColor(_filteredScans[index].spots);

                return FlDotCirclePainter(
                  radius: isTouched ? 6 : 4,
                  color: color,
                  strokeWidth: isTouched ? 2 : 0,
                  strokeColor: Theme.of(context).cardColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        extraLinesData: _showAverageLine
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: _averageValue * _animation.value,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      labelResolver: (line) =>
                          'Avg: ${_averageValue.toStringAsFixed(1)}',
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildChartTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChartTypeButton(
            icon: Icons.bar_chart,
            isActive: _currentView == ChartView.bar,
            onTap: () => setState(() => _currentView = ChartView.bar),
          ),
          _buildChartTypeButton(
            icon: Icons.show_chart,
            isActive: _currentView == ChartView.line,
            onTap: () => setState(() => _currentView = ChartView.line),
          ),
          _buildChartTypeButton(
            icon: Icons.area_chart,
            isActive: _currentView == ChartView.area,
            onTap: () => setState(() => _currentView = ChartView.area),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
      ),
    );
  }

  List<Color> _getBarGradient(int spots) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (spots <= 5) {
      return isDarkMode
          ? [const Color(0xFF00C853), const Color(0xFF69F0AE)]
          : [const Color(0xFF00E676), const Color(0xFF69F0AE)];
    } else if (spots <= 10) {
      return isDarkMode
          ? [const Color(0xFFFFD600), const Color(0xFFFFFF8D)]
          : [const Color(0xFFFFEE58), const Color(0xFFFFFF8D)];
    } else if (spots <= 15) {
      return isDarkMode
          ? [const Color(0xFFFF9100), const Color(0xFFFFE0B2)]
          : [const Color(0xFFFFB74D), const Color(0xFFFFE0B2)];
    } else {
      return isDarkMode
          ? [const Color(0xFFFF1744), const Color(0xFFFF8A80)]
          : [const Color(0xFFFF5252), const Color(0xFFFF8A80)];
    }
  }

  Color _getSpotColor(int spots) {
    if (spots <= 5) {
      return const Color(0xFF00E676);
    } else if (spots <= 10) {
      return const Color(0xFFFFEE58);
    } else if (spots <= 15) {
      return const Color(0xFFFFB74D);
    } else {
      return const Color(0xFFFF5252);
    }
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  String _formatDateLong(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  double _calculateMaxY(List<ScanModel> scans) {
    if (scans.isEmpty) return 10;
    final maxSpots = scans.map((scan) => scan.spots).reduce(max);
    return maxSpots.toDouble() * 1.1;
  }

  double _calculateInterval(List<ScanModel> scans) {
    final maxY = _calculateMaxY(scans);
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return 20;
  }
}
