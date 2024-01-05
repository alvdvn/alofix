import 'package:base_project/common/themes/colors.dart';
import 'package:base_project/common/utils/global_app.dart';
import 'package:base_project/config/fonts.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangeSelection extends StatefulWidget {
  const DateRangeSelection({super.key, this.title, this.dateRange});

  final String? title;
  final DateTimeRange? dateRange;

  @override
  State<DateRangeSelection> createState() => _DateRangeSelectionState();
}

class _DateRangeSelectionState extends State<DateRangeSelection> {
  String? errorText;
  DateTime? start;
  DateTime? end;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        start = widget.dateRange?.start;
        end = widget.dateRange?.end;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _DateRangeSelectionHeader(
          title: widget.title,
          start: start,
          end: end,
        ),
        SfDateRangePicker(
          startRangeSelectionColor: AppColor.colorRedMain,
          endRangeSelectionColor: AppColor.colorRedMain,
          rangeSelectionColor: AppColor.colorRed,
          onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
            PickerDateRange pickerDateRange =
                dateRangePickerSelectionChangedArgs.value as PickerDateRange;
            setState(() {
              errorText = null;
              start = pickerDateRange.startDate;
              end = pickerDateRange.endDate;
            });
          },
          initialSelectedRange:
              PickerDateRange(widget.dateRange?.start, widget.dateRange?.end),
          selectionMode: DateRangePickerSelectionMode.range,
          selectionTextStyle: FontFamily.normal(color: Colors.white),
          headerStyle: DateRangePickerHeaderStyle(
            textStyle: FontFamily.normal(
              size: 17,
              color: AppColor.colorRedMain,
            ).copyWith(letterSpacing: 0.5),
          ),
          yearCellStyle: DateRangePickerYearCellStyle(
            textStyle: FontFamily.normal(size: 15),
            leadingDatesTextStyle: FontFamily.normal(),
            disabledDatesTextStyle: FontFamily.normal(),
            todayTextStyle: FontFamily.normal(),
          ),
          monthCellStyle: DateRangePickerMonthCellStyle(
            textStyle: FontFamily.normal(),
            todayTextStyle: FontFamily.normal(),
            todayCellDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: AppColor.colorRedMain,
              ),
            ),
          ),
          rangeTextStyle: FontFamily.normal(size: 15),
          monthViewSettings: DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1,
            enableSwipeSelection: false,
            viewHeaderStyle: DateRangePickerViewHeaderStyle(
              textStyle: FontFamily.normal(size: 15),
            ),
          ),
          monthFormat: 'MMMM',
        ),
        if (errorText != null) ...{
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              errorText.toString(),
              style: FontFamily.normal(color: Colors.red),
            ),
          )
        },
        const SizedBox(height: 36),
        _DateRangeSelectionAction(
          onCancelPressed: () {
            Navigator.pop(context);
          },
          onConfirmPressed: () {
            if (start == null) {
              setState(() {
                errorText = 'Ngày bắt đầu không thể trống!';
              });
              return;
            }
            if (end == null) {
              setState(() {
                errorText = 'Ngày kết thúc không thể trống!';
              });
              return;
            }
            Navigator.pop(
              context,
              DateTimeRange(
                start: start!,
                end: end!
                    .add(const Duration(hours: 23, minutes: 59, seconds: 59)),
              ),
            );
          },
        )
      ],
    );
  }
}

class _DateRangeSelectionHeader extends StatelessWidget {
  const _DateRangeSelectionHeader({
    Key? key,
    this.title,
    this.start,
    this.end,
  }) : super(key: key);
  final String? title;
  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.only(left: 24, right: 12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        color: AppColor.colorRedMain,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            title ?? 'Chọn phạm vi ngày',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.white, fontSize: 18),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngày bắt đầu',
                style: FontFamily.normal(color: Colors.white)
                    .copyWith(letterSpacing: 1.0),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  start == null ? '' : ddMMYYYYSlashFormat.format(start!),
                  style: FontFamily.normal(
                    size: 16,
                    color: Colors.white,
                  ).copyWith(letterSpacing: 1.0),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngày kết thúc',
                style: FontFamily.normal(
                  color: Colors.white,
                ).copyWith(letterSpacing: 1.0),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  end == null ? '' : ddMMYYYYSlashFormat.format(end!),
                  style: FontFamily.normal(
                    color: Colors.white,
                  ).copyWith(letterSpacing: 1.0),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DateRangeSelectionAction extends StatelessWidget {
  const _DateRangeSelectionAction(
      {Key? key, this.onConfirmPressed, this.onCancelPressed})
      : super(key: key);
  final VoidCallback? onConfirmPressed;
  final VoidCallback? onCancelPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      constraints: const BoxConstraints(minHeight: 52.0),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: OverflowBar(
        spacing: 8,
        children: <Widget>[
          TextButton(
            onPressed: onCancelPressed,
            child: Text('HỦY', style: FontFamily.normal(size: 13)),
          ),
          TextButton(
            onPressed: onConfirmPressed,
            child: Text('OK', style: FontFamily.normal(size: 13)),
          ),
        ],
      ),
    );
  }
}
