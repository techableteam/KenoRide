import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/Global_variable.dart';
import 'package:kenorider_driver/view_models/request_view_model.dart';
import 'package:kenorider_driver/views/arrivedpickuppage.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../common/stoplocation.dart';

class RideRequestDialog extends StatefulWidget {
  const RideRequestDialog({super.key});

  @override
  RideRequestDialogState createState() => RideRequestDialogState();
}

class RideRequestDialogState extends State<RideRequestDialog> {
  
  bool _isLoading = false;
  final logger = Logger();
  void _onRequestPress(BuildContext context) async {

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final response = await context.read<RequestViewModel>().acceptRequest();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if(response == 200) {
      GlobalVariables.progress = 4;
      
      // Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ArrivePickupPointPage()),
      );
    } else if (response == 404) {
      logger.i("This is not found request");
    } else {
      logger.i('Internal server error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestmodel = Provider.of<RequestViewModel>(context);
    String? period = requestmodel.request.period;
    String? start = requestmodel.request.startLocation;
    String? end = requestmodel.request.endLocation;
    String? cost = requestmodel.request.cost;
    String? riderName = requestmodel.request.riderName;
    double? rating = requestmodel.request.rating;
    String? distance = requestmodel.request.distance;
    // int? orderID = requestmodel.request.orderID;
    List<StopLocation>? stopLocations = requestmodel.request.stopLocations;

    logger.i("Stop locations: $stopLocations");

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ride Request!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '\$$cost',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow),
                    Text('$rating',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Estimated time: $period',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  'Distance: $distance',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$riderName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '$start',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Displaying stop locations
            // 
            if (stopLocations != null && stopLocations.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stopLocations.length,
                itemBuilder: (context, index) {
                  final stop = stopLocations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0), // Added padding for space
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 30),
                        Text('Stop ${index + 1}:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            stop.address.toString(),
                            maxLines: null,
                            softWrap: true,
                            style: const TextStyle(color: Colors.grey)
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              const Text(' '),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.pink),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        '$end',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      GlobalVariables.flag = false;
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: const Text('Decline',
                                  style: TextStyle(
                                    color:Colors.black,
                                    fontSize: 16,
                                  ),),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      _onRequestPress(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:ColorManager.primarycolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                    ),
                    child: _isLoading ?
                    const Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                    : const Text('Accept',  style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
