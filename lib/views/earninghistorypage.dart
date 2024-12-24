import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/services/useDio.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/earningmodel.dart';
import 'package:logger/logger.dart';

class EarningHistoryPage extends StatefulWidget {
  const EarningHistoryPage({super.key});

  @override
  EarningHistoryPageState createState() => EarningHistoryPageState();
}

class EarningHistoryPageState extends State<EarningHistoryPage> {
  List<Earning> earnings = [];
  List<dynamic> reviews = [];
  bool isLoading = true; // To handle loading state
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchEarnings();
    fetchReviewData(); // Fetch review data on page load
  }

  Future<List<dynamic>> getHistory() async {
    final DioService dioService = DioService();
    final driverID = localStorage.getItem('driverID');
    
    if (driverID == null) {
      throw Exception("Driver ID is not found in local storage");
    }

    final data = {
      "driver_id": int.parse(driverID),
    };

    final response = await dioService.postRequest("/getDriverHistory", data: data);

    if (response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('history')) {
        return responseData['history'] as List<dynamic>;
      } else {
        throw Exception("Unexpected response format: 'history' key not found");
      }
    } else {
      throw Exception("Unexpected response format");
    }
  }

  Future<void> fetchEarnings() async {
    try {
      List<dynamic> historyData = await getHistory();

      setState(() {
        earnings = historyData.map((item) {
          final dateTime = DateTime.parse(item['updated_at']);
          final date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
          final time = "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

          return Earning(
            from: item['start_location'] ?? 'Unknown',
            to: item['end_location'] ?? 'Unknown',
            date: date,
            time: time,
            amount: item['cost'],
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      logger.i("Error fetching earnings: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchReviewData() async {
    try {
      final DioService dioService = DioService();
      final driverID = localStorage.getItem('driverID');
      
      if (driverID == null) {
        throw Exception("Driver ID is not found in local storage");
      }

      final data = {
        "driver_id": int.parse(driverID),
      };

      final response = await dioService.postRequest("/getReviewData", data: data);
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          setState(() {
            reviews = responseData['data'] as List<dynamic>;
          });
        } else {
          throw Exception("Unexpected response format: 'data' key not found");
        }
      }
    } catch (e) {
      logger.i("Error fetching review data: $e");
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);

    // Use `LaunchMode.externalApplication` to force it to open in an external browser.
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(Apptext.backIconImage),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Center(
          child: Text(
            Apptext.earningHistoryPageTitleText,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 26,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 1),
                                reviews.isEmpty 
                                ? const Center(child: Text('No data')) :
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: reviews.length,
                                  itemBuilder: (context, index) {
                                    final review = reviews[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8.0), // Add some spacing between cards
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Colors.grey, // Set the color of the border
                                          width: 0.5, // Set the width of the border
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2), // Set shadow color
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2), // Changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text('To ${review['first_name']}'),
                                        subtitle: Row(children: [
                                          Text("Cost: \$${review['type']},"),
                                          const SizedBox(width: 20,),
                                          Text("Rating: ${review['rating']}.0"),
                                        ],),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.receipt),
                                          onPressed: () async{
                                            await _launchURL(review['receipt_url']);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  // Expanded(
                  //   child: ListView.builder(
                  //     itemCount: earnings.length,
                  //     itemBuilder: (context, index) {
                  //       return Padding(
                  //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //         child: Row(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Image.asset(Apptext.carIconImage, width: 44, height: 44),
                  //             const SizedBox(width: 10),
                  //             Expanded(
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   RichText(
                  //                     text: TextSpan(
                  //                       children: [
                  //                         TextSpan(
                  //                           text: '${earnings[index].from} ',
                  //                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  //                         ),
                  //                         const TextSpan(
                  //                           text: 'to ',
                  //                           style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),
                  //                         ),
                  //                         TextSpan(
                  //                           text: '${earnings[index].to}',
                  //                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                   const SizedBox(height: 4),
                  //                   Text(
                  //                     '${earnings[index].date} - ${earnings[index].time}',
                  //                     style: TextStyle(color: Colors.grey[600]),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //             const SizedBox(width: 10),
                  //             Column(
                  //               children: [
                  //                 const SizedBox(height: 35),
                  //                 Text(
                  //                   '\$${earnings[index].amount}',
                  //                   style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15),
                  //                 ),
                  //               ],
                  //             )
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
    );
  }
}
