import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
// import 'dart:js_interop'; //unused import
import 'package:vm_service/vm_service.dart' show VmService;
import 'package:vm_service/vm_service_io.dart' as vms;
import 'package:vm_service/utils.dart' as vmutils;
import 'package:watcher/watcher.dart';

// Recharge watches for changes in given path and reloads
// VM on an event. It reports back this with the onReload
// callback.
class Recharge {
  final String path;
  final void Function()? onReload;
  int delay;
  bool clearConsole;

  String? _mainIsolate;
  VmService? _service;
  late DirectoryWatcher _watcher;
  Timer? _timer;

  Recharge(
      {required this.path,
      this.onReload,
      int delay = 200,
      bool clearConsole = true})
      : delay = delay,
        clearConsole = clearConsole {
    // This instance of watcher is going to be alive
    // throughout the execution
    _watcher = DirectoryWatcher(path);

    // Start watching for file changes in the path
    _clearConsole();
    print("Starting recharge..");
    _watcher.events.listen((event) async {
      var name = event.type.toString().toUpperCase();
      var path = event.path;
      print("$name $path");
      _timer?.cancel();
      _timer = Timer(Duration(milliseconds: this.delay), () async {
        _clearConsole();
        await reload();

        onReload?.call();
      });
    });
  }

  // init builds websocket endpoint from observatory URL
  //  and fetches main isolate's id
  init() async {
    // Observatory URL is like: http://127.0.0.1:8181/u31D8b3VvmM=/
    // Websocket endpoint for that will be: ws://127.0.0.1:8181/reBbXy32L6g=/ws

    // print("application reloaded")

    final serverUri = (await dev.Service.getInfo()).serverUri;
    if (serverUri == null) {
      throw Exception("No VM service. Run with --enable-vm-service");
    }
    final wsUri = vmutils.convertToWebSocketUrl(serviceProtocolUrl: serverUri);

    // Get VM service
    _service = await vms.vmServiceConnectUri(wsUri.toString());

    // Get currently running VM
    final vm = await _service!.getVM();

    // Fetch main isolate's id
    _mainIsolate = vm.isolates!.first.id;
  }

  // Reloads the main isolate and return whether it was successful or not
  Future<bool> reload() async {
    if (_service == null) {
      throw Exception("Recharge not initilized. Call init() with await.");
    }
    // Reload main isolate. This only reloads the code. Nothing is executed
    // or no data is modified after this.
    final res = await _service!.reloadSources(_mainIsolate!);

    // Log the result of reload. If it was a failure print the message
    // from reload report. This map is not documented. It may change I guess.
    // Hence inside a try catch.
    if (res.success!) {
      print("Reload success");
    } else {
      print("Reload failed");
      try {
        print(res.json!["notices"][0]["message"]);
      } catch (e) {}
    }

    return res.success!;
  }

  // source https://stackoverflow.com/questions/21269769/clearing-the-terminal-screen-in-a-command-line-dart-app
  _clearConsole() {
    if (clearConsole) print("\x1B[2J\x1B[0;0H");
  }
}
