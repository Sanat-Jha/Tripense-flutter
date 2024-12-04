import 'package:flutter/material.dart';
import 'package:tripense/fetchfunction.dart';
import 'package:tripense/trippage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> futureTrips;

  @override
  void initState() {
    super.initState();
    futureTrips = fetchTrips();
  }

  // Function to fetch trips from the API
  Future<List<Map<String, dynamic>>> fetchTrips() async {
    final tripIdList = await getTripIdList(); 
    // final tripIdList = [1, 2,3]; // Dummy trip ID list
    final response = await fetchData(
      "home/",
      {"tripidlist": tripIdList},
    );

    if (response != null && response["trips"] != null) {
      return List<Map<String, dynamic>>.from(response["trips"]);
    } else {
      return []; // Return empty list if no data or error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/Tripense.png',
              height: 200,
            ),
            ElevatedButton(
              onPressed: () => _showNewTripDialog(context),
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
                  SizedBox(width: 10),
                  Text(
                    "New Trip",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: "mainfont",
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: futureTrips,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return  Center(
                      child: Text('Error loading trips ${snapshot.error.toString()}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No trips available'),
                    );
                  } else {
                    List<Map<String, dynamic>> trips = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1,
                      ),
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return InkWell(
                          onLongPress: () {
                            _showDeleteDialog(trip["id"], trip["title"]);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TripPage(tripid: trip["id"],)),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.black),
                            ),
                            child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text(
                                  trip['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${trip['totalmembers']} People',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${trip['paymentpermember']} Rps/person',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            
                                                          ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showDeleteDialog(int tripId, String tripTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete $tripTitle?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // API call to delete trip
                String url = 'deletetrip/';
                await fetchData(url, {'tripid': tripId});

                Navigator.pop(context);
                setState(() {
                  futureTrips = fetchTrips(); // Refresh trips list after deletion
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  // Function to show the dialog for entering the new trip title
  void _showNewTripDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Trip'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Trip Title',
              hintText: 'Enter your trip title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String title = _controller.text.trim();

                if (title.isNotEmpty) {
                  Map<String, dynamic> data = {'title': title};

                  var response = await fetchData('newtrip/', data);

                  if (response != null) {
                    var trips = await getTripIdList();
                    saveTripIdList(trips + [response['id']]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Trip created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {
                      futureTrips = fetchTrips(); // Refresh the trips list
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create trip.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trip title cannot be empty.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );
  }
}
