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
