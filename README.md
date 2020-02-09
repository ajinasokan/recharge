# Recharge

Recharge is a simple library to hot reload your Dart code on file changes. This is useful when you are building Dart CLIs or API services. It utilises Dart VM's hot reloading and incremental build capabilities through [vm_service](https://pub.dev/packages/vm_service) library. To use Recharge check out following examples and run your code like this:

```shell
dart --enable-vm-service main.dart
```

## Hello world

Run following code and then change print string and save. Recharge will detect file modification and reload code. To execute main again `onReload` callback of Recharge is used.

```dart
import 'package:recharge/recharge.dart';

// Build recharge. Execute main after reload.
var recharge = Recharge(
  path: ".",
  onReload: () => main(),
);

void main() async {
  // Initialize recharge
  await recharge.init();

  // Say hello. After running change this text
  // and save it again.
  print("Hello world!");
}
```

## HTTP Server

Here we don't execute main after reload because server will be running even after reload. And functions will be replaced. So make any change to handle function and save. Refresh `http://localhost:8080` in browser and you should see the change.

```dart
import 'dart:io';
import 'package:recharge/recharge.dart';

// Build recharge. Not using callback because after
// code change functions will be replaced. Execution will
// happen when next time request hits the server.
var recharge = Recharge(path: ".");

void main() async {
  // Initialize recharge
  await recharge.init();

  // Simple HTTP server
  var server = await HttpServer.bind("localhost", 8080);
  await for (var request in server) {
    handle(request, request.response);
  }
}

// Say hello to everyone
void handle(HttpRequest req, HttpResponse res) {
  res.write("Hello there!");
  res.close();
}
```

## Decoupling

If you are writing a serious project you want Recharge separate from your main code. You can create another `main_debug.dart` like below and use that while developing instead.

```dart
import 'package:recharge/recharge.dart';
import 'main.dart' as realMain;

// Build recharge. Execute main after reload.
var recharge = Recharge(
  path: ".",
  onReload: () => main(),
);

void main() async {
  // Initialize recharge
  await recharge.init();

  // Execute actual main function
  realMain.main();
}
```

## Why

It was initially written in early 2018 when I was building a code generator for a Flutter project. For every modification I had to run the code again with Dart CLI. Since it is a cold start of VM for every execution it was really slow. So I looked at Flutter source code and figured out how hot reload is done and coupled it with [watcher](https://pub.dev/packages/watcher) library. Fast forward to 2020 and I was making a Youtube video about stateful hot reloading and thought why not make this a library. So here it is.