import 'package:flutter/material.dart';

class MySearchDelegate extends SearchDelegate {
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: (() => close(context, null)), icon: const Icon(Icons.arrow_back));

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
        ),
      ];

  @override
  Widget buildResults(BuildContext context) => Center(
        child: Text(
          query,
        ),
      );

  @override
  Widget buildSuggestions(BuildContext contex) {
    List<String> suggestions = [
      '',
      '',
      '',
      '',
      '',
      '',
    ];

    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: (() {
              query = suggestion;
              showResults(context);
            }),
          );
        });
  }
}
