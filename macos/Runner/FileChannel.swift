//
//  FileChannel.swift
//  Runner
//
//  Created by 王文 on 2020/11/9.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import FlutterMacOS
import Foundation

public class FileChannel:NSObject,FlutterPlugin{
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "plugins.flutter.file_channel",
            binaryMessenger:registrar.messenger)
        let instance = FileChannel()
        registrar.addMethodCallDelegate(instance, channel:channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method{
        case "getResourcesADBPath":
            let adbPath = Bundle(for: FileChannel.self).path(forResource: "adb", ofType: nil)
            result(adbPath)
        case "getDesktopPath":
            result(getDirectory(ofType:FileManager.SearchPathDirectory.desktopDirectory))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

private func getDirectory(ofType directory: FileManager.SearchPathDirectory) -> String? {
    let paths = NSSearchPathForDirectoriesInDomains(
        directory,
        FileManager.SearchPathDomainMask.userDomainMask,
        true)
    return paths.first
}
