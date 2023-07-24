import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplemail/screens/search_screen/search_controller.dart';
import 'package:simplemail/screens/home_screen/view/homemessage_body.dart';
import 'package:simplemail/screens/home_screen/widgets/list_items.dart';
import 'package:simplemail/services/auth_service.dart';

class EmailSearchDelegate extends SearchDelegate {
  final SearchController searchController = Get.put(SearchController());

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchHistory();
  }

  @override
  void showResults(BuildContext context) {
    _addToSearchHistory(query);
    searchController.performSearch(query);
    super.showResults(context);
  }

  Widget _buildSearchResults() {
    return GetBuilder<SearchController>(
      builder: (searchController) {
        if (searchController.isLoading &&
            searchController.isListMoreLoading == false) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            controller: searchController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: searchController.gmailDetail.length + 1,
            itemBuilder: (context, index) {
              if (index == searchController.gmailDetail.length) {
                return searchController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Container();
              } else {
                // GmailMessage message = messages[index];
                return GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GmailMessageBody(
                          i: index,
                          message: searchController.gmailDetail[index], threadId: '',isStarred: searchController
                                                .gmailDetail[index].labelIds!
                                                .contains('Starred')
                                            ? false
                                            : true,
                        ),
                      ),
                    );
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? token = prefs.getString('token');

                    await AuthService().markMessageAsSeen(
                        messageId: searchController.gmailDetail[index].id!,
                        accessToken: token!);
                  },
                  child: ListItems(
                    isStarred: searchController
                                                .gmailDetail[0].labelIds!
                                                .contains('STARRED')
                                            ? true
                                            : false ,
                    i: index,
                    date: searchController.getFormattedDate(int.tryParse(
                            searchController
                                .gmailDetail[index].internalDate!) ??
                        0),
                    from: searchController.gmailDetail[index].payload?.headers
                            ?.where((element) => element.name == "From")
                            .toList()
                            .first
                            .value ??
                        '',
                    subject: searchController
                            .gmailDetail[index].payload!.headers!
                            .contains('Subject')
                        ? searchController.gmailDetail[index].payload?.headers
                                ?.where((element) => element.name == "Subject")
                                .toList()
                                .first
                                .value ??
                            ''
                        : 'Subject',
                    snippet: searchController.gmailDetail[index].snippet ?? '',
                    isRead: searchController.gmailDetail[index].labelIds!
                            .contains('UNREAD')
                        ? false
                        : true,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildSearchHistory() {
    return FutureBuilder<List<String>>(
      future: _getSearchHistory(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> history = snapshot.data ?? [];
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final itemKey = GlobalKey();
              return Dismissible(
                key: itemKey,
                background: Container(color: Colors.red),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  String removedItem = history[index];
                  // Remove the dismissed item from the search history
                  history.removeAt(index);
                  await _saveSearchHistory(history);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Removed '$removedItem' from search history"),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          history.insert(index, removedItem);
                          await _saveSearchHistory(history);
                          showSuggestions(context);
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.history)),
                  title: Text(history[index]),
                  onTap: () {
                    query = history[index];
                    showResults(context);
                  },
                ),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future<void> _addToSearchHistory(String term) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('searchHistory') ?? [];
    if (!history.contains(term)) {
      history.add(term);
      await prefs.setStringList('searchHistory', history);
    }
  }

  Future<List<String>> _getSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('searchHistory') ?? [];
  }

  Future<void> _saveSearchHistory(List<String> history) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', history);
  }

  Future<void> clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
  }

  Color generateRandomColor(String name) {
    int hash = name.hashCode;
    Random random = Random(hash);
    return EmailSearchDelegate
        .colorList[random.nextInt(EmailSearchDelegate.colorList.length)];
    // Color.fromRGBO(
    //   random.nextInt(256),
    //   random.nextInt(256),
    //   random.nextInt(256),
    //   1,
    // );
  }

  static final List<Color> colorList = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    // Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];
}
