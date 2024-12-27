import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:green_house/detail.dart';

class BluetoothControlScreen extends StatefulWidget {
  const BluetoothControlScreen({super.key});

  @override
  _BluetoothControlScreenState createState() => _BluetoothControlScreenState();
}

class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Green house Controller'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Bluetooth State: $_bluetoothState'),
                const SizedBox(height: 16),
                _bluetoothState != BluetoothState.STATE_ON
                    ? ElevatedButton(
                        onPressed: () async {
                          await FlutterBluetoothSerial.instance.requestEnable();
                        },
                        child: const Text('Turn On'))
                    : FutureBuilder<List<BluetoothDevice>>(
                        future:
                            FlutterBluetoothSerial.instance.getBondedDevices(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            final devices = snapshot.data;
                            return devices != null
                                ? Expanded(
                                    child: ListView.builder(
                                      itemCount: devices.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            dense: true,
                                            tileColor: const Color.fromARGB(
                                                255, 191, 211, 158),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailPage(
                                                      device: devices[index],
                                                    ),
                                                  ));
                                            },
                                            leading: const Icon(Icons.devices),
                                            title: Text(devices[index].name ??
                                                "Unknown device"),
                                            subtitle: Text(devices[index]
                                                .address
                                                .toString()),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const Center(child: Text('No Devices Found'));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
              ],
            )));
  }
}
