import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfiniteScrollPage extends StatefulWidget {
  const InfiniteScrollPage({Key? key}) : super(key: key);

  @override
  State<InfiniteScrollPage> createState() => _InfiniteScrollPageState();
}

class _InfiniteScrollPageState extends State<InfiniteScrollPage> {
  ScrollController _scrollController = ScrollController();
  List<dynamic> issues = [];
  int currentPage = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initial API call
    _getIssues();
    // Add a listener to the scroll controller
    _scrollController.addListener(() {
      // Check if the user has scrolled to the bottom
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Fetch the next page of data
        _getIssues();
      }
    });
  }

  Future<void> _getIssues() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      // Replace this URL with your actual API endpoint
      String apiUrl = 'https://api.github.com/repositories/1300192/issues?page=$currentPage';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> newIssues = json.decode(response.body);
        print(response);
        setState(() {
          issues.addAll(newIssues);
          currentPage++;
          isLoading = false;
        });

        // Scroll to the top after loading new issues
        _scrollController.jumpTo(0.0);
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page $currentPage',style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: issues.length + 1,
        itemBuilder: (context, index) {
          if (index == issues.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            var issue = issues[index];
            return Column(
              children: [
                ListTile(
                  title: Text(issue['title'] ?? 'No title'),
                  subtitle: Text(issue['body'] ?? 'No description'),
                  onLongPress: (){
                    showDialog(context: context, builder: (BuildContext context){
                      return Dialog(
                        child: Center(child: Text('Its ${issue['title'] ?? 'No title'}')),
                      );
                    }
                    );
                  },
                ),
                Divider(),
              ],
            );
          }
        },
        controller: _scrollController,
      ),
    );
  }
}
