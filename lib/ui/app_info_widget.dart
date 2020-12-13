import 'package:flutter_phone_helper/data/app_info.dart';
import 'package:flutter_phone_helper/data/device.dart';
import 'package:flutter_phone_helper/utils/app_shell.dart';
import 'package:flutter_phone_helper/widght/dialogs.dart';
import 'package:flutter_phone_helper/widght/imageg_text_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widght/wdigets.dart';

class AppInfoWidget extends StatefulWidget {
  const AppInfoWidget({Key key, this.device})
      : assert(device != null),
        super(key: key);

  final Device device;

  @override
  State<StatefulWidget> createState() => _AppInfoWidgetState();
}

class _AppInfoWidgetState extends State<AppInfoWidget> {
  AppInfo _appInfo;

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  Future _getAppInfo() async {
    var appInfo = await getAppInfo(widget.device.id);
    if (mounted) setState(() => _appInfo = appInfo);
  }

  void _clearAppData() {
    if (_appInfo == null) return;
    String appId = _appInfo.appId;

    showAlertDialog(
      context,
      title: "风险提示",
      message: '是否要清除应用数据？\nID：$appId',
      negative: '取消',
      onNegativePressed: () => Navigator.of(context).pop(),
      positive: '清除',
      onPositivePressed: () {
        Navigator.of(context).pop();
        clearAppData(widget.device.id, _appInfo?.appId);
      },
    );
  }

  void _uninstallApp() {
    if (_appInfo == null) return;
    String appId = _appInfo.appId;

    showAlertDialog(
      context,
      title: "风险提示",
      message: '是否要卸载App ？\nID：$appId',
      negative: '取消',
      onNegativePressed: () => Navigator.pop(context),
      positive: '卸载',
      onPositivePressed: () async {
        Navigator.pop(context);
        await uninstallApp(widget.device.id, _appInfo?.appId);
        _getAppInfo();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconTextButton(
              icon: Icons.info_outline,
              text: "App信息",
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
                  onPressed: () => _getAppInfo(),
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Table(
            border: TableBorder.all(color: Colors.white),
            columnWidths: {0: FlexColumnWidth(0.5)},
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  buildTabText("App ID"),
                  buildTabText(_appInfo?.appId),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("版本号"),
                  buildTabText(_appInfo?.versionCode),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("版本名称"),
                  buildTabText(_appInfo?.versionName),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("SDK版本"),
                  buildTabText(_appInfo?.sdk),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("当前Activity"),
                  buildTabText(_appInfo?.currentActivity),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            IconTextButton(
              icon: Icons.settings,
              text: "打开设置",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () async {
                await _getAppInfo();
                openAppSettings(widget.device.id, _appInfo?.appId)
                    .withProgressDialog(context);
              },
            ),
            Expanded(child: SizedBox()),
            IconTextButton(
              icon: Icons.delete,
              text: "清除数据",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () async {
                await _getAppInfo();
                _clearAppData();
              },
            ),
            Expanded(child: SizedBox()),
            IconTextButton(
              icon: Icons.power_off,
              text: "清空权限",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () async {
                await _getAppInfo();
                revokePermissions(widget.device.id, _appInfo)
                    .withProgressDialog(context);
              },
            ),
            Expanded(child: SizedBox()),
            IconTextButton(
              icon: Icons.delete_forever,
              text: "卸载应用",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () async {
                await _getAppInfo();
                _uninstallApp();
              },
            ),
          ],
        ),
      ],
    );
  }
}
