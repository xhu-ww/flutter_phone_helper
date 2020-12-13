import 'dart:async';

import 'package:flutter_phone_helper/data/device.dart';
import 'package:flutter_phone_helper/src/colors.dart';
import 'package:flutter_phone_helper/utils/pair.dart';
import 'package:flutter_phone_helper/widght/dialogs.dart';
import 'package:flutter_phone_helper/widght/wdigets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_helper/utils/device_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'app_info_widget.dart';
import 'device_info_widget.dart';

class HomePage extends StatefulWidget {
  HomePage() : super(key: homeKey);

  @override
  State<StatefulWidget> createState() => _HomePageState();

  static GlobalKey<_HomePageState> homeKey = GlobalKey<_HomePageState>();
}

class _HomePageState extends State<HomePage> {
  List<Device> _devices;
  int _currentSelectedIndex = 0;

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

  Future refresh() {
    return getConnectedDevices().then((value) {
      if (mounted) {
        setState(() => _devices = value);
      }
    });
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
        await connectDeviceByIp(editingController.text.trim());
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
    var bgColor = _bgColors[5];

    Device currentDevice;
    if (_devices?.isEmpty ?? true) {
      _currentSelectedIndex = 0;
    } else {
      if (_currentSelectedIndex >= _devices.length) {
        _currentSelectedIndex = _devices.length - 1;
      }
      currentDevice = _devices[_currentSelectedIndex];
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          decoration: _createGradientDecoration(bgColor.first),
          child: Stack(
            children: [
              currentDevice == null
                  ? Center(
                      child: Text(
                        "当前无连接的设备。\n左侧区域可下拉刷新设备列表，[+] 按钮可添加设备。",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    )
                  : SizedBox(),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Expanded(
                          child: EasyRefresh.custom(
                            header: createIOSHeader(),
                            onRefresh: refresh,
                            slivers: <Widget>[
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      _buildDeviceItem(_devices[index], index),
                                  childCount: _devices?.length ?? 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 24),
                          width: double.infinity,
                          child: IconButton(
                            icon:
                                Icon(Icons.add, color: Colors.white, size: 32),
                            tooltip: "添加设备",
                            onPressed: () => _addDevice(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: currentDevice == null
                        ? SizedBox()
                        : Container(
                            decoration:
                                _createGradientDecoration(bgColor.second),
                            child: ListView(
                              padding: EdgeInsets.all(16),
                              children: [
                                DeviceInfoWidget(device: currentDevice),
                                const SizedBox(height: 16),
                                AppInfoWidget(device: currentDevice),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceItem(Device device, int index) {
    if (device == null) return SizedBox();

    return GestureDetector(
      onTap: () {
        getDeviceDetail(device.id);
        setState(() => _currentSelectedIndex = index);
      },
      child: Container(
        height: 36,
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: index == _currentSelectedIndex
              ? AppColors.transparent_gray
              : Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(
              device.connectedByWifi ? Icons.wifi : Icons.phone_iphone_outlined,
              color: Colors.white,
              size: 16,
            ),
            Expanded(
              child: Text(
                device.name ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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
