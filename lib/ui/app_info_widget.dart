import 'dart:io';

import 'package:flutter_phone_helper/process/device.dart';
import 'package:flutter_phone_helper/process/device_app.dart';
import 'package:flutter_phone_helper/process/system.dart';
import 'package:flutter_phone_helper/widght/dialogs.dart';
import 'package:flutter_phone_helper/widght/imageg_text_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widght/wdigets.dart';

class AppInfoWidget extends StatefulWidget {
  final Device device;

  const AppInfoWidget({required this.device});

  @override
  State<StatefulWidget> createState() => _AppInfoWidgetState();
}

class _AppInfoWidgetState extends State<AppInfoWidget> {
  void _clearAppData(DeviceApp app) {
    showAlertDialog(
      context,
      title: "风险提示",
      message: '是否要清除应用数据？\nID：${app.appId}',
      negative: '取消',
      onNegativePressed: () => Navigator.of(context).pop(),
      positive: '清除',
      onPositivePressed: () {
        Navigator.of(context).pop();
        app.clearAppData();
      },
    );
  }

  void _uninstallApp(DeviceApp app) {
    showAlertDialog(
      context,
      title: "风险提示",
      message: '是否要卸载App ？\nID：${app.appId}',
      negative: '取消',
      onNegativePressed: () => Navigator.pop(context),
      positive: '卸载',
      onPositivePressed: () async {
        Navigator.pop(context);
        await app.uninstallApp();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeviceApp>(
      future: widget.device.currentFocusApp(),
      builder: (context, snapshot) {
        var app = snapshot.data;
        if (app == null) {
          return Center(child: CupertinoActivityIndicator());
        }
        return Column(
          children: [
            Row(
              children: [
                IconTextButton(
                  icon: Icons.info_outline,
                  text: "屏幕最上层App信息",
                  orientation: WidgetOrientation.horizontal,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      tooltip: "更新App信息",
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                app.icon == null
                    ? SizedBox(width: 24.0)
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Image.file(
                          File(app.icon!),
                          fit: BoxFit.contain,
                          width: 120.0,
                        ),
                      ),
                Expanded(
                  child: Table(
                    border: TableBorder.all(color: Colors.white),
                    columnWidths: {0: FlexColumnWidth(0.5)},
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          buildTabText("ID"),
                          buildTabText(app.appId),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          buildTabText("名称"),
                          buildTabText(app.label),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          buildTabText("版本号"),
                          buildTabText(app.versionCode),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          buildTabText("版本名称"),
                          buildTabText(app.versionName),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          buildTabText("SDK版本"),
                          buildTabText(app.sdk),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          buildTabText("当前Activity"),
                          buildTabText(app.currentActivity),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0)
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconTextButton(
                  icon: Icons.settings,
                  text: "打开设置",
                  textStyle: TextStyle(color: Colors.white, fontSize: 14),
                  onTap: () async {
                    setState(() {});
                    app.openAppSettings().withProgressDialog(context);
                  },
                ),
                Expanded(child: SizedBox()),
                IconTextButton(
                  icon: Icons.delete,
                  text: "清除数据",
                  textStyle: TextStyle(color: Colors.white, fontSize: 14),
                  onTap: () async {
                    setState(() {});
                    _clearAppData(app);
                  },
                ),
                Expanded(child: SizedBox()),
                IconTextButton(
                  icon: Icons.power_off,
                  text: "清空权限",
                  textStyle: TextStyle(color: Colors.white, fontSize: 14),
                  onTap: () async {
                    setState(() {});
                    app.revokePermissions().withProgressDialog(context);
                  },
                ),
                Expanded(child: SizedBox()),
                IconTextButton(
                  icon: Icons.delete_forever,
                  text: "卸载应用",
                  textStyle: TextStyle(color: Colors.white, fontSize: 14),
                  onTap: () async {
                    setState(() {});
                    _uninstallApp(app);
                  },
                ),
                IconTextButton(
                  icon: Icons.save_alt,
                  text: "导出APK",
                  textStyle: TextStyle(color: Colors.white, fontSize: 14),
                  onTap: () async {
                    var apkPath = await app.analyzeApk();
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconTextButton(
                  icon: Icons.apps,
                  text: "已安装的App",
                  orientation: WidgetOrientation.horizontal,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      tooltip: "更新App信息",
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
