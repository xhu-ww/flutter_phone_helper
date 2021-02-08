import 'dart:io';

import 'package:flutter_phone_helper/data/data_manager.dart';
import 'package:flutter_phone_helper/process/device.dart';
import 'package:flutter_phone_helper/process/scrcpy.dart';
import 'package:flutter_phone_helper/process/system.dart';
import 'package:flutter_phone_helper/utils/shell.dart';
import 'package:flutter_phone_helper/widght/imageg_text_button.dart';
import 'package:flutter_phone_helper/widght/screen_record_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_helper/widght/dialogs.dart';

import '../widght/wdigets.dart';
import 'home_page.dart';

class DeviceInfoWidget extends StatefulWidget {
  final Device device;

  const DeviceInfoWidget({required this.device});

  @override
  State<StatefulWidget> createState() => _DeviceInfoWidgetState();
}

class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  final textEditingController = TextEditingController();

  void _openUrl(String url) {
    widget.device.openLink(url);
    urlSchemes.add(url);
    setState(() {});
  }

  void _shareScreen() async {
    var scrcpyExists = await File(scrcpyPath).exists();

    if (scrcpyExists) {
      int sdkVersion = 21;

      try {
        sdkVersion = int.parse(widget.device.sdk ?? '0');
      } catch (e) {
        print(e);
      }

      if (sdkVersion < 21) {
        showAlertDialog<bool>(
          context,
          message: "当前设备SDK为$sdkVersion,设备投屏最低支持SDK版本为21",
          negative: "关闭",
          onNegativePressed: () => Navigator.pop(context),
        );
      } else {
        shareScreen(widget.device.id);
      }
    } else {
      var download = await showAlertDialog<bool>(
        context,
        title: "插件下载",
        message: "设备投屏需要下载投屏核心库",
        negative: "取消",
        onNegativePressed: () => Navigator.pop(context),
        positive: "下载",
        onPositivePressed: () =>
            Navigator.of(context, rootNavigator: true).pop(true),
      );

      if (download ?? false) {
        system
            .downloadScrcpy()
            .withProgressDialog(context)
            .whenComplete(() => _shareScreen());
      }
    }
  }

  void _screenshotAndShow() async {
    var imagePath =
        await widget.device.screenshot().withProgressDialog(context);
    if (imagePath != null) {
      system.openFile(imagePath);
    }
  }

  void _shareDevice() async {
    var ip = await widget.device.openTcpConnect();
    var tipMessage = ip ? "请连接WIFI" : "设备IP地址: $ip";

    showAlertDialog(
      context,
      title: "分享设备",
      message: tipMessage,
      negative: "关闭",
      onNegativePressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconTextButton(
          icon: Icons.perm_device_info,
          text: "设备信息",
          orientation: WidgetOrientation.horizontal,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Table(
            border: TableBorder.all(color: Colors.white),
            columnWidths: {0: FlexColumnWidth(0.5)},
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  buildTabText("名称"),
                  buildTabText(widget.device.name),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("系统版本"),
                  buildTabText(widget.device.versionName),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("ABI"),
                  buildTabText(widget.device.abiList),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("屏幕分辨率"),
                  buildTabText(widget.device.physicalSize),
                ],
              ),
              TableRow(
                children: <Widget>[
                  buildTabText("屏幕密度"),
                  buildTabText(widget.device.density),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            widget.device.connectedByWifi
                ? IconTextButton(
                    icon: Icons.wifi,
                    text: "断开WIFI",
                    onTap: () async {
                      await widget.device.disconnectWifi();
                      HomePage.homeKey.currentState?.refresh();
                    },
                  )
                : IconTextButton(
                    icon: Icons.wifi_off,
                    text: "WIFI连接",
                    onTap: () async {
                      await widget.device.connectWifi();
                      HomePage.homeKey.currentState?.refresh();
                    },
                  ),
            Expanded(child: SizedBox()),
            IconTextButton(
              icon: Icons.add_to_home_screen,
              text: "设备投屏",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () => _shareScreen(),
            ),
            Expanded(child: SizedBox()),
            IconTextButton(
              icon: Icons.camera_alt,
              text: "截取屏幕",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () => _screenshotAndShow(),
            ),
            Expanded(child: SizedBox()),
            IconTextButton(
              icon: Icons.videocam,
              text: "录制视频",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () {
                if (widget.device.name?.contains("HUAWEI") ?? false) {
                  showAlertDialog(
                    context,
                    message: "当前设备无法录制视频",
                    negative: "关闭",
                    onNegativePressed: () => Navigator.pop(context),
                  );
                } else {
                  showScreenRecordDialog(context, widget.device);
                }
              },
            ),
            Expanded(child: SizedBox()),
            IconTextButton(
              icon: Icons.mobile_screen_share,
              text: "分享设备",
              textStyle: TextStyle(color: Colors.white, fontSize: 14),
              onTap: () => _shareDevice(),
            ),
          ],
        ),
        TextField(
          style: TextStyle(color: Colors.white, fontSize: 14),
          controller: textEditingController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.link, color: Colors.white),
            hintText: '输入网址或URL Scheme',
            hintStyle: TextStyle(color: Colors.white, fontSize: 14),
            suffixIcon: IconButton(
              padding: EdgeInsets.only(right: 16),
              icon: Icon(
                Icons.subdirectory_arrow_right,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => _openUrl(textEditingController.text.trim()),
              tooltip: '执行',
            ),
          ),
          onSubmitted: (value) => _openUrl(value),
        ),
      ],
    );
  }
}
