import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T> showProgressDialog<T>(BuildContext context,
    {Future<T> Function() run}) async {
  showDialog(
    context: context,
    child: Center(
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: CupertinoActivityIndicator(radius: 16),
      ),
    ),
  );

  return (run?.call() ?? Future.delayed(Duration(seconds: 1))).whenComplete(() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  });
}

Widget tipDialog(Widget tipIcon, {String tip}) {
  assert(tipIcon != null);
  return Center(
    child: Container(
      height: 132,
      width: 132,
      padding: EdgeInsets.all(16),
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: (tip?.isEmpty ?? true) ? Colors.transparent : Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          tipIcon,
          if (tip != null) ...[
            SizedBox(height: 8),
            Text(
              tip,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            )
          ]
        ],
      ),
    ),
  );
}

Future<void> showSuccessDialog(BuildContext context, String tip,
    {bool barrierTransparent = false}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: barrierTransparent ? Color(0x00FFFFFF) : Colors.black26,
    builder: (context) => tipDialog(
      Icon(Icons.check_circle, size: 24),
      tip: tip,
    ),
  );
  await Future.delayed(Duration(seconds: 2));
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

extension ProgressDialogExt<T> on Future<T> {
  Future<T> withProgressDialog(BuildContext context) {
    return showProgressDialog(context, run: () async => await this);
  }

  Future<T> withSuccessDialog(BuildContext context, {String successTip}) {
    return showProgressDialog(context, run: () async {
      final res = await this;
      await showSuccessDialog(context, successTip, barrierTransparent: true);
      return res;
    });
  }
}

Future<T> showAlertDialog<T>(
  BuildContext context, {
  String title,
  String message,
  Widget content,
  String negative,
  String positive,
  VoidCallback onNegativePressed,
  VoidCallback onPositivePressed,
}) {
  return showDialog<T>(
    context: context,
    child: AlertDialog(
      title: title?.isEmpty ?? true ? null : Text(title),
      content: content ??
          SelectableText(message ?? "", style: TextStyle(fontSize: 14)),
      actions: [
        negative != null
            ? TextButton(
                child: Text(negative),
                onPressed: () => onNegativePressed?.call(),
              )
            : SizedBox(),
        positive != null
            ? TextButton(
                child: Text(positive),
                onPressed: () => onPositivePressed?.call(),
              )
            : SizedBox(),
      ],
    ),
  );
}
