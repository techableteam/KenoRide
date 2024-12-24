import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/Global_variable.dart';
import 'package:kenorider_driver/common/colormanager.dart';
import 'package:kenorider_driver/common/textcontent.dart';
import 'package:kenorider_driver/view_models/request_view_model.dart';
import 'package:kenorider_driver/views/mainpage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class RatePage extends StatefulWidget {
  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  int _selectedRating = 0;
  TextEditingController _reviewController = TextEditingController();
  FocusNode _reviewFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isReviewFocused = false;

  @override
  void initState() {
    super.initState();
    _reviewFocusNode.addListener(() {
      setState(() {
        _isReviewFocused = _reviewFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _reviewFocusNode.dispose();
    super.dispose();
  }

  void _onSubmitButtonPress() async{
    // if (_reviewController.text.isEmpty || _selectedRating == 0) {
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: const Text('Warning'),
    //       content: const Text('Please leave a review and select a rate.'),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     ),
    //   );
    // } else {
      final response = await context.read<RequestViewModel>().reviewSubmit(_selectedRating.toString(), _reviewController.text);
      if(response == 200) {
        setState(() {
          _isLoading = true; // Toggle loading state
        });
        localStorage.removeItem("riderID");
        GlobalVariables.progress = 0;

        // Simulate a delay before reloading the page
        Future.delayed(const Duration(seconds: 4), () {
          // Remove all previous routes and push the new route
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainPage()),
            (Route<dynamic> route) => false,
          );
        });
        print(response);
      }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final requestmodel = Provider.of<RequestViewModel>(context);
    // String driverName = localStorage.getItem("driverName").toString();
    String? riderName = requestmodel.request.riderName;
    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder enabledInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        ColorManager.primarycolor,
                        ColorManager.darkprimarycolor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const Spacer(),
                          const Text(
                            'Rate your Passenger',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!_isReviewFocused) ...[
                        CircleAvatar(
                          // backgroundImage: NetworkImage(GlobalVariables.driverPhoto),
                          backgroundImage: AssetImage(Apptext.riderAvatarImage),
                          radius: 45,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          riderName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: index < _selectedRating ? ColorManager.buttonStarColor : Colors.grey,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _reviewController,
                              focusNode: _reviewFocusNode,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: 'Leave a Review',
                                labelStyle: const TextStyle(color: Colors.black),
                                hintText: "The passenger is so kind and honest:D ",
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                focusedBorder: focusedBorder,
                                enabledBorder: enabledInputBorder,
                              ),
                            ),
                            const SizedBox(height: 80), // Add space to avoid overlap with the button
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _onSubmitButtonPress,
                  // ignore: sort_child_properties_last
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.darkprimarycolor,
                          ColorManager.primarycolor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(
                        maxWidth: double.infinity,
                        minHeight: 45,
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 24.0, // Custom width
                                height: 24.0, // Custom height
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3.0, // Optional: custom stroke width
                                ),
                              ),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            topLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Image.asset(Apptext.allArrivedImage),
                            const SizedBox(height: 20),
                            const Text(
                              'Rate Succeed!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'You will automatically direct back to the Homepage in a moment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
