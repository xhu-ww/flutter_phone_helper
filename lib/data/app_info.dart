class AppInfo {
  String appId;
  String? versionName;
  String? versionCode;
  String? sdk;
  String? currentActivity;
  List<String>? permissions;

  AppInfo({
    required this.appId,
    this.versionName,
    this.versionCode,
    this.sdk,
    this.currentActivity,
    this.permissions,
  });
}
