import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/library_state.dart';
import '../playlists/add_to_playlist_sheet.dart';
import 'folder_detail_screen.dart';

class FoldersTab extends StatelessWidget {
  const FoldersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryState>();
    final folders = library.folders;

    if (folders.isEmpty) return const Center(child: Text('No folders found.'));

    return ListView.builder(
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.folder)),
          title: Text(folder.name),
          subtitle: Text('${folder.songs.length} songs', maxLines: 1),
          trailing: IconButton(
            icon: const Icon(Icons.add_to_photos_outlined),
            tooltip: 'Add folder to playlist',
            onPressed: () => showAddToPlaylistSheet(context, folder.songs),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => FolderDetailScreen(folderPath: folder.path)),
          ),
        );
      },
    );
  }
}
