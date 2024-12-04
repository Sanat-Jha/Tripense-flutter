import 'package:flutter/material.dart';
import 'package:tripense/fetchfunction.dart';

class PaymentsPage extends StatefulWidget {
  final int tripid;
  const PaymentsPage({super.key, required this.tripid});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: fetchData("trip/", {"tripid": widget.tripid}),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final trip = snapshot.data;
              final List<dynamic> members = trip["members"];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/img/Tripense.png',
                      height: 100,
                    ),
                    Text(
                      "${trip["title"]} Payments",
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.black,
                          fontFamily: "mainfont",
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showNewPaymentDialog(context, members);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "New Payment",
                            style: TextStyle(
                                fontSize: 15, color: Colors.white, fontFamily: "mainfont"),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: trip["payments"].length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(trip["payments"][index]["shop"].toString()),
                                    Text(trip["payments"][index]["member"].toString()),
                                    Text(trip["payments"][index]["amount"].toString()),
                                    InkWell(
                                      onTap: () async {
                                        var response = await fetchData(
                                          "removepayment/",
                                          {
                                            "tripid": widget.tripid,
                                            "payment": trip["payments"][index],
                                          },
                                        );

                                        if (response != null) {
                                          setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Payment removed successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Some error occurred.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Icon(Icons.delete, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 1, color: Colors.black),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showNewPaymentDialog(BuildContext context, List<dynamic> members) {
    final TextEditingController shopController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String? selectedMember;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Paying Member'),
                items: members
                    .map<DropdownMenuItem<String>>(
                      (member) => DropdownMenuItem<String>(
                        value: member.toString(), // Convert to String here
                        child: Text(member.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedMember = value;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String shop = shopController.text.trim();
                String amountText = amountController.text.trim();
                double? amount = double.tryParse(amountText);

                if (shop.isNotEmpty && selectedMember != null && amount != null) {
                  var response = await fetchData(
                    "newpayment/",
                    {
                      "tripid": widget.tripid,
                      "shop": shop,
                      "member": selectedMember,
                      "amount": amount,
                    },
                  );

                  if (response != null) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add payment.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields correctly.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
