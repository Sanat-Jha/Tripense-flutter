import 'package:flutter/material.dart';
import 'package:tripense/fetchfunction.dart';
class MembersPage extends StatefulWidget {
  final int tripid;
  const MembersPage({super.key, required this.tripid});

  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late int tripid;

  @override
  void initState() {
    super.initState();
    tripid = widget.tripid; // Initialize the tripid variable
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: fetchData("trip/", {"tripid": tripid}),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Failed to load trip data'),
              );
            } else {
              final trip = snapshot.data;
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
                      "${trip["title"]} Members",
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontFamily: "mainfont",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final TextEditingController _controller =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Add New Member'),
                              content: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  labelText: 'Member Name',
                                  hintText: 'Enter member name',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    String name = _controller.text.trim();
                                    if (name.isNotEmpty) {
                                      Map<String, dynamic> data = {
                                        'tripid': widget.tripid,
                                        'name': name,
                                      };

                                      var response = await fetchData('newmember/', data);

                                      if (response != null && response["status"] == "success") {
                                        setState(() {});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Member added successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else if (response != null && response["status"] == "Member already exists in the trip") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Member already exists in the trip.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Failed to add member.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Member name cannot be empty.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
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
                            "Add Member",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: "mainfont"),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: trip["totalmembers"],
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(trip["members"][index]),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () async {
                                        var response = await fetchData("removemember/", {
                                          "tripid": tripid,
                                          "name": trip["members"][index],
                                        });

                                      if (response != null) {
                                        setState(() {});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Member removed successfully!'),
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
                                        );
                                      }
                                      }
                                      ,child: const Icon(Icons.close, color: Colors.black)),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.black,
                              ),
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
}
