import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({required this.device, super.key});

  final BluetoothDevice device;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  BluetoothConnection? _connection;
  bool _isConnected = false;
  String _receivedData = "";
  String temperature = "--";
  String humidity = "--";
  String light = "--";
  String moisture = "--";

  bool isItManual = false;

  Future<void> _connect() async {
    try {
      await BluetoothConnection.toAddress(widget.device.address).then(
        (connection) {
          print('Connected to the device');

          setState(() {
            _connection = connection;
            _isConnected = true;
          });

          _connection!.input!.listen(onDataReceived).onDone(() {
            setState(() {
              _isConnected = false;
            });
            print('Disconnected by remote device.');
          });
        },
      );
    } catch (e) {
      print('Connection failed: $e');
      setState(() {
        _isConnected = false;
      });
     
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Connection failed: ${e.toString()}'),
      ));
    }
  }

  void onDataReceived(Uint8List data) {

    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    _receivedData = String.fromCharCodes(buffer);
    print(_receivedData);
  }



  void sendData(String data) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(utf8.encode("$data\n"));
    }
  }


  Future<void> _disconnect() async {
    await _connection?.close();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.device.name ?? "Unknown device";
    String address = widget.device.address;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Green house Controller'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(address),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_isConnected) {
                          _disconnect();
                        } else {
                          _connect();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          _isConnected ? Colors.red : Colors.green,
                        ),
                      ),
                      child: Text(
                        _isConnected ? 'Disconnect' : 'Connect',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _isConnected
                    ? Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isItManual = !isItManual;
                                if (isItManual) {
                                  sendData("YES");
                                } else {
                                  sendData("NO");
                                }
                              });
                            },
                            child: Text(isItManual ? 'MANUAL' : 'AUTO'),
                          ),
                          GridView(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12),
                            children: [
                              SensorContainer(
                                label: 'Temperature',
                                data: sendData,
                              ),
                              SensorContainer(
                                label: 'Moisture',
                                data: sendData,
                              ),
                               SensorContainer(
                                label: 'Light',
                                data: sendData,
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Text('please connect it'),
              ],
            )));
  }
}

class SensorContainer extends StatefulWidget {
  final String label;

  final Function data;

  const SensorContainer({super.key, required this.label, required this.data});

  @override
  State<SensorContainer> createState() => _SensorContainerState();
}

class _SensorContainerState extends State<SensorContainer> {
  String switchButton = 'OFF';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 191, 211, 158),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton(
                  onPressed: switchButton == 'OFF'
                      ? () {
                          switchButton = 'ON';
                          setState(() {
                            widget.data('${widget.label}$switchButton');
                          });
                        }
                      : () {
                          switchButton = 'OFF';
                          setState(() {
                            widget.data('${widget.label}$switchButton');
                          });
                        },
                  child: Text(switchButton))
            ],
          ),
        ),
      ),
    );
  }
}
