import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// providers
import '../providers/providers.dart';

// widgets
import '../widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // text editing controller
  final _controller = TextEditingController();

  // this will hold the search query
  String _searchQuery = '';

  @override
  void dispose() {
    super.dispose();

    // controller dispose
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFCFCF),
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search ...',
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.cancel_outlined),
              color: Colors.grey,
              onPressed: () {
                setState(() {
                  _controller.clear();
                  _searchQuery = '';
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          cursorColor: Colors.grey,
          style: const TextStyle(
            color: Colors.white,
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<SavedScansProvider>(
        builder: (context, obj, child) {
          // if query is empty then return
          if (_searchQuery.isEmpty) {
            return const Center(
              child: Text('Please search for something!'),
            );
          }

          // getting the results
          final results = obj.getSearchResults(_searchQuery);

          // if there are no results
          if (results.isEmpty) {
            return const Center(
              child: Text('No results found!'),
            );
          }

          // if there are results
          return ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return SavedScanTile(results[index]);
            },
          );
        },
      ),
    );
  }
}
