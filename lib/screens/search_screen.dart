import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../state/library_state.dart';
import '../state/player_state.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final playerState = context.read<PlayerState>();

    final q = _query.toLowerCase();
    final List<Song> results = q.isEmpty
        ? const []
        : library.songs
            .where((s) =>
                s.title.toLowerCase().contains(q) ||
                s.artist.toLowerCase().contains(q) ||
                s.album.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, albums',
            border: InputBorder.none,
          ),
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(fontSize: 18, fontWeight: FontWeight.normal),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: q.isEmpty
          ? const Center(child: Text('Search your library'))
          : results.isEmpty
              ? const Center(child: Text('No results'))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) => SongTile(
                    song: results[index],
                    onTap: () => playerState.playQueue(results, startIndex: index, sourceLabel: 'Search results'),
                  ),
                ),
    );
  }
}
