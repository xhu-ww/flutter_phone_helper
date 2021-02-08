import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildTabText(String? content) {
  return Container(
    padding: EdgeInsets.all(8),
    child: SelectableText(
      content ?? "",
      style: TextStyle(color: Colors.white, fontSize: 13),
      maxLines: 1,
    ),
  );
}

// Header createIOSHeader() {
//   return CustomHeader(
//     enableInfiniteRefresh: false,
//     extent: 40.0,
//     triggerDistance: 50.0,
//     headerBuilder: (context,
//         loadState,
//         pulledExtent,
//         loadTriggerPullDistance,
//         loadIndicatorExtent,
//         axisDirection,
//         float,
//         completeDuration,
//         enableInfiniteLoad,
//         success,
//         noMore) {
//       return Stack(
//         children: <Widget>[
//           Positioned(
//             bottom: 0.0,
//             left: 0.0,
//             right: 0.0,
//             child: Container(
//               width: 30.0,
//               height: 30.0,
//               child: CupertinoActivityIndicator(),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
