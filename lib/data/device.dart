class Device {
  String id;
  String name;
  String abiList;
  String versionName;
  String sdk;
  String physicalSize;
  String density;

  bool connectedByWifi;

  Device({
    this.id,
    this.name,
    this.abiList,
    this.versionName,
    this.sdk,
    this.physicalSize,
    this.density,
  });
}
