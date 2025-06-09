import 'package:flutter/material.dart';

import '../model/dtos/QuestionDTO.dart';

class QuestionSearchDelegate extends SearchDelegate {
  final List<QuestionDTO> questions;

  QuestionSearchDelegate(this.questions);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = questions.where((q) {
      return q.title.toLowerCase().contains(query.toLowerCase()) ||
          q.textQ.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].title),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = questions.where((q) {
      return q.title.toLowerCase().contains(query.toLowerCase()) ||
          q.textQ.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].title),
        );
      },
    );
  }
}
