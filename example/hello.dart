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
