import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'global.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  TextEditingController passenger_name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController passenger_age = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  String passengerId = "";

  List<Passenger> reservationList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Reservation Page"),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  clearScreen();
                },
                child: const Text("New")),
            ElevatedButton(
                onPressed: () {
                  if (formGlobalKey.currentState!.validate()) {
                    saveRecord();
                  }
                },
                child: const Text("Save"))
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formGlobalKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 250,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name is required";
                  }
                },
                controller: passenger_name,
                decoration: const InputDecoration(labelText: "Name"),
              ),
            ),
            SizedBox(
              width: 300,
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: address,
                decoration: const InputDecoration(labelText: "Address"),
              ),
            ),
            SizedBox(
              width: 50,
              child: TextFormField(
                controller: passenger_age,
                decoration: const InputDecoration(labelText: "Age"),
              ),
            ),
            FutureBuilder(
              future: getList(),
              builder: (context, snapshot) {
                return Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: reservationList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 181, 220, 237),
                            border: Border(
                                bottom: BorderSide(color: Colors.black))),
                        child: InkWell(
                          onTap: () {
                            passengerId = reservationList[index].id.toString();
                            passenger_name.text =
                                reservationList[index].passenger_name ?? "";

                            passenger_age.text =
                                reservationList[index].passenger_age.toString();

                            

                          },
                          child: ListTile(
                            leading: const Icon(Icons.man),
                            title: Text(reservationList[index].passenger_name ?? ""),
                            subtitle:
                                Text(" Age : ${reservationList[index].passenger_age}"),
                            trailing: ElevatedButton(
                                onPressed: () {
                                  passengerId = reservationList[index].id.toString();
                                  deleteRecord();
                                },
                                child: const Text("Delete")),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> saveRecord() async {
    try {
      Map<String, dynamic> body = {
        'id': passengerId,
        'passenger_name': passenger_name.text,
        'passenger_age': passenger_age.text,
        'address': address.text,
      };

      Uri url = Uri.parse("http://localhost:8080/passenger/createrecord");
      if (passengerId.isNotEmpty) {
        url = Uri.parse("http://localhost:8080/passenger/updaterecord");
      }

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      String msg = data["message"];
      if (msg.toLowerCase().contains("success")) {
        showMessage(context, msg);
        if (passengerId.isEmpty) {
          passengerId = data["id"].toString();
        }
        clearScreen();
        setState(() {});
        print("msg = $msg");
      } else {
        showMessage(context, msg);
        print("msg = $msg");
      }
    } catch (e) {
      showMessage(context, "Error : $e");
      print("msg = $e}");
    }
  }

  Future<void> getList() async {
    try {
      Map<String, dynamic> body = {
        'user_id': "test",
      };

      Uri url = Uri.parse("http://localhost:8080/passenger/getlist");

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      String msg = data["message"];
      if (msg.toLowerCase().contains("success")) {
        var jsonData = data["listData"];

        reservationList.clear();
        jsonData.forEach((jsonItem) {
          Passenger passenger = Passenger();
          passenger.id = jsonItem['id'];
          passenger.passenger_name = jsonItem['passenger_name'];
          passenger.passenger_age = jsonItem['passenger_age'];
          passenger.address= jsonItem['address'];

          reservationList.add(passenger);
        });

        print(reservationList.length);

        //clearScreen();
        print("msg = $msg");
      } else {
        showMessage(context, msg);
        print("msg = $msg");
      }
    } catch (e) {
      showMessage(context, "Error : $e");
      print("msg = $e}");
    }
  }

  Future<void> deleteRecord() async {
    try {
      Map<String, dynamic> body = {
        'id': passengerId,
        'passenger_name': passenger_name.text,
        'passenger_age': passenger_age.text,
        'address':address.text,
      };

      if (passengerId.isEmpty) {
        showMessage(context, "Select a record...");
      }

      Uri url = Uri.parse("http://localhost:8080/passenger/deleterecord");

      final response = await http.post(
        url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = jsonDecode(response.body);
      String msg = data["message"];
      if (msg.toLowerCase().contains("success")) {
        showMessage(context, msg);

        clearScreen();
        setState(() {});
        print("msg = $msg");
      } else {
        showMessage(context, msg);
        print("msg = $msg");
      }
    } catch (e) {
      showMessage(context, "Error : $e");
      print("msg = $e}");
    }
  }

  void clearScreen() {
    passengerId = "";
    passenger_name.text = "";
    address.text = "";
    passenger_age.text = "";
  }
}

class Passenger {
  int? id;
  String? passenger_name;
  String? address;
  int? passenger_age;
}