import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_helper/src/colors.dart';
import 'package:flutter_phone_helper/utils/device_shell.dart';
import 'package:flutter_phone_helper/utils/shell.dart';

Future showScreenRecordDialog(BuildContext context, String deviceId) {
  return showDialog(
    context: context,
    child: Center(
      child: ScreenRecordDialog(deviceId: deviceId),
    ),
  );
}

class ScreenRecordDialog extends StatefulWidget {
  ScreenRecordDialog({Key key, this.deviceId})
      : assert(deviceId != null),
        super(key: key);

  final String deviceId;

  @override
  State<StatefulWidget> createState() => ScreenRecordDialogState();
}

class ScreenRecordDialogState extends State<ScreenRecordDialog> {
  bool _onRecording = false;
  int totalTime = 0;
  Timer _timer;

  final _bgDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: AppColors.gradient_group_5_left,
    ),
  );

  final TextStyle _textStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  List<TextInputFormatter> _inputFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(4),
  ];

  final TextEditingController _rateController =
      TextEditingController(text: "4");
  final TextEditingController _widthController =
      TextEditingController(text: "720");
  final TextEditingController _heightController =
      TextEditingController(text: "1280");

  @override
  Widget build(BuildContext context) {
    return _onRecording
        ? Container(
            width: 128,
            height: 128,
            decoration: _bgDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$totalTime s", style: _textStyle),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: _stopScreenRecord,
                  child: Icon(
                    Icons.stop_circle_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text("屏幕录制中...", style: _textStyle),
              ],
            ),
          )
        : Container(
            width: 460,
            height: 240,
            padding: EdgeInsets.only(left: 24, top: 24, right: 24),
            decoration: _bgDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "屏幕录制最多可以记录3分钟。\n"
                  "默认情况下，以设备的原始分辨率或720p的4 Mbps比特率录制。\n"
                  "您可以在下面自定义这些选项，最低分辨率为96x64px。\n"
                  "分辨率必须是16的倍数。保留为空以使用默认值。",
                  style: _textStyle,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text("比特率(Mbps)：", style: _textStyle),
                    Expanded(
                      flex: 2,
                      child: CupertinoTextField(
                        inputFormatters: _inputFormatter,
                        controller: _rateController,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("视频宽*高(px)：", style: _textStyle),
                    Expanded(
                      child: CupertinoTextField(
                        inputFormatters: _inputFormatter,
                        controller: _widthController,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CupertinoTextField(
                        controller: _heightController,
                        inputFormatters: _inputFormatter,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      TextButton(
                        child: Text("取消录屏"),
                        onPressed: closeDialog,
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        child: Text("开始录屏"),
                        onPressed: _screenRecord,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }

  void _screenRecord() {
    setState(() => _onRecording = true);
    screenRecord(
      deviceId: widget.deviceId,
      rate: int.parse(_rateController.text),
      width: int.parse(_widthController.text),
      height: int.parse(_heightController.text),
    ).then((value) => openFile(value)).whenComplete(() {
      if (Navigator.canPop(context)) closeDialog();
    });

    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) => setState(() => totalTime += 1),
    );
  }

  void _stopScreenRecord() {
    _timer?.cancel();
    stopScreenRecord(widget.deviceId);
  }

  void closeDialog() => Navigator.of(context).pop();
}
