import 'dart:async';

import 'package:flutter_phone_helper/process/device.dart';
import 'package:flutter_phone_helper/process/adb.dart';
import 'package:flutter_phone_helper/src/colors.dart';
import 'package:flutter_phone_helper/utils/pair.dart';
import 'package:flutter_phone_helper/widght/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_helper/widght/label_page_selector.dart';
import 'app_info_widget.dart';
import 'device_info_widget.dart';

class HomePage extends StatefulWidget {
  HomePage() : super(key: homeKey);

  @override
  State<StatefulWidget> createState() => _HomePageState();

  static GlobalKey<_HomePageState> homeKey = GlobalKey<_HomePageState>();
}

class _HomePageState extends State<HomePage> {
  final List<Device> _devices = [];
  var _leftMenuSelectedIndex = 0;
  var _rightLabelSelectedIndex = 0;
  var _pageController = PageController();

  final _bgColors = [
    Pair(AppColors.gradient_group_0_left, AppColors.gradient_group_0_right),
    Pair(AppColors.gradient_group_1_left, AppColors.gradient_group_1_right),
    Pair(AppColors.gradient_group_2_left, AppColors.gradient_group_2_right),
    Pair(AppColors.gradient_group_3_left, AppColors.gradient_group_3_right),
    Pair(AppColors.gradient_group_4_left, AppColors.gradient_group_4_right),
    Pair(AppColors.gradient_group_5_left, AppColors.gradient_group_5_right),
  ];

  @override
  void initState() {
    super.initState();
    refresh();
    Timer.periodic(Duration(seconds: 5), (timer) => refresh());
  }

  Future<void> refresh() async {
    var list = await adb.deviceIds();
    if (mounted) {
      setState(() {
        _devices.clear();
        _devices.addAll(list);
      });
    }
  }

  void _addDevice() async {
    TextEditingController editingController = TextEditingController();

    showAlertDialog(
      context,
      title: '添加设备',
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('设备IP：'),
          Expanded(
            child: CupertinoTextField(
              controller: editingController,
              inputFormatters: [LengthLimitingTextInputFormatter(15)],
            ),
          ),
        ],
      ),
      negative: '取消',
      onNegativePressed: () => Navigator.of(context).pop(),
      positive: "连接",
      onPositivePressed: () async {
        Navigator.of(context).pop();
        await adb.connectDeviceByIp(editingController.text.trim());
        refresh();
      },
    );
  }

  BoxDecoration _createGradientDecoration(List<Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var bgColor = _bgColors[0];

    Device? device;
    if (_devices.isEmpty) {
      _leftMenuSelectedIndex = 0;
    } else {
      if (_leftMenuSelectedIndex >= _devices.length) {
        _leftMenuSelectedIndex = _devices.length - 1;
      }
      device = _devices[_leftMenuSelectedIndex];
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: device == null
            ? Container(
                alignment: Alignment.center,
                decoration: _createGradientDecoration(bgColor.first),
                child: Text(
                  "当前无连接的设备。\n左侧区域可下拉刷新设备列表，[+] 按钮可添加设备。",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: _createGradientDecoration(bgColor.first),
                      child: _buildLeftMenu(),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: _createGradientDecoration(bgColor.second),
                      child: Column(
                        children: [
                          const SizedBox(height: 45.0),
                          LabelPageSelector(
                            ['设备详情', 'App详情'],
                            height: 32.0,
                            groupValue: _rightLabelSelectedIndex,
                            borderColor: Colors.white,
                            selectedColor: AppColors.transparent_gray,
                            unselectedColor: Colors.transparent,
                            labelPadding: EdgeInsets.symmetric(horizontal: 32),
                            onSelectedChanged: (value) {
                              setState(() {
                                _rightLabelSelectedIndex = value;
                              });
                              _pageController.animateToPage(
                                value,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                          ),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _rightLabelSelectedIndex = index;
                                });
                              },
                              children: <Widget>[
                                DeviceInfoWidget(device: device),
                                AppInfoWidget(device: device),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLeftMenu() {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Column(
        children: [
          const SizedBox(height: 45.0),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) =>
                  _buildDeviceItem(_devices[index], index),
              itemCount: _devices.length,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 24.0),
            width: double.infinity,
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 32.0),
              tooltip: "添加设备",
              onPressed: () => _addDevice(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(Device device, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _leftMenuSelectedIndex = index);
      },
      child: Container(
        height: 36.0,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: index == _leftMenuSelectedIndex
              ? AppColors.transparent_gray
              : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
        child: Row(
          children: [
            Icon(
              device.connectedByWifi ? Icons.wifi : Icons.phone_iphone_outlined,
              color: Colors.white,
              size: 16.0,
            ),
            Expanded(
              child: Text(
                device.name ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
