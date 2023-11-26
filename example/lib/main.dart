import 'package:flutter/material.dart';
import 'dart:async';
import 'package:device_details_plugin/device_details_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DeviceDetailsPlugin _deviceDetails = DeviceDetailsPlugin();

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getDeviceInfo() async {
    final DeviceDetailsPlugin? details = await DeviceDetailsPlugin.getDeviceInfo();
    print(details);
    setState(() {
      _deviceDetails = details!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: _deviceDetails == null
              ? CircularProgressIndicator()
              : _showInfo()
      ),
    );
  }

  _showInfo() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("app name: ${_deviceDetails.appName}"),
          Text("package name: ${_deviceDetails.packageName}"),
          Text("version name: ${_deviceDetails.version}"),
          Text("build: ${_deviceDetails.buildNumber}"),
          Text("flutter app version: ${_deviceDetails.flutterAppVersion}"),
          Text("os version: ${_deviceDetails.osVersion}"),
          Text("total internal storage: ${_deviceDetails.totalInternalStorage}"),
          Text("free internal storage: ${_deviceDetails.freeInternalStorage}"),
          Text("mobile operator: ${_deviceDetails.networkOperator}"),
          Text("total ram size: ${_deviceDetails.totalRAMSize}"),
          Text("free ram size: ${_deviceDetails.freeRAMSize}"),
          Text("screen size: ${_deviceDetails.screenSizeInInches}"),
          Text("current date and time: ${_deviceDetails.currentDateTime}"),
          Text("manufacturer: ${_deviceDetails.manufacturer}"),
          Text("device id: ${_deviceDetails.deviceId}"),
        ],
      ),
    );
  }
}
