import 'package:flutter/material.dart';
import 'package:tripense/fetchfunction.dart';
import 'package:tripense/memberspage.dart';
import 'package:tripense/paymentspage.dart';

class TripPage extends StatefulWidget {
  final int tripid;
  const TripPage({super.key, required this.tripid});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData("trip/", {"tripid": widget.tripid}),
      builder: (context, snapshot){ 
        if (!snapshot.hasData) { return const Center(child: CircularProgressIndicator()); }
        else{
          final trip = snapshot.data;
          return Scaffold(
        backgroundColor: Colors.white,
      
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
              'assets/img/Tripense.png',
              height: 100,
            ),
                Text(trip["title"],
                style: const TextStyle(fontSize: 45, color: Colors.black, fontFamily: "mainfont", fontWeight: FontWeight.w700),),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    
                    ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  MembersPage(tripid :trip["id"])),
                          );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    elevation: 5, // Shadow elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Sharp edges
                    ),
                    side: const BorderSide(color: Colors.white), // Border color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${trip["totalmembers"]} Members",
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: "mainfont"),
                      )
                    ],
                  ),
                ),ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PaymentsPage(tripid :trip["id"])),
                          );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    elevation: 5, // Shadow elevation
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Sharp edges
                    ),
                    side: const BorderSide(color: Colors.white), // Border color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Payments",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: "mainfont"),
                      )
                    ],
                  ),
                ),
                  ]
                ),
                const SizedBox(height: 20),
                            Text("${trip["totalpayment"]}  ruppess spent",
                style: const TextStyle(fontSize: 25, color: Colors.black, fontFamily: "mainfont", fontWeight: FontWeight.w200),),
                const SizedBox(height: 10),
                            Text("${trip["paymentpermember"]}  ruppess per person",
                style: const TextStyle(fontSize: 25, color: Colors.black, fontFamily: "mainfont", fontWeight: FontWeight.w200),),
                const SizedBox(height: 15),
                            const Text("Friends Dues",
                style: TextStyle(fontSize: 15, color: Colors.black, fontFamily: "mainfont", fontWeight: FontWeight.w700),),
                const SizedBox(height: 10),
                 Expanded(
              child: ListView.builder(
                itemCount: trip["dues"].length, // Change this to your required item count
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: trip["dues"][index][2]>0?[
                                Text(trip["dues"][index][0]),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(trip["dues"][index][1]),
                              ]
                              :
                              [
                                Text(trip["dues"][index][1]),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Colors.black),
                                const SizedBox(width: 8),
                                Text(trip["dues"][index][0]),
                              ],
                            ),
                            Text(trip["dues"][index][2].abs().toString()),
                            Checkbox(
                              value: trip["dues"][index][3] != 0 && trip["dues"][index][3], // Default state
                              onChanged: (bool? value) async{
                           
                                        var response = await fetchData("toggledue/", {
                                          "tripid": widget.tripid,
                                          "dueindex": index,
                                          "toggle": value,
                                        });

                                      if (response != null) {
                                        setState(() {});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(response["message"]),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Some error occurred.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );}
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.black), // Horizontal line
                    ],
                  );
                },
              ),
            )
              ]
            ),
          ),
        )
      );}}
    );
  }
}