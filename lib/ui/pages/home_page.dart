import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:notes_app/core/controllers/note_controller.dart';
import 'package:notes_app/core/models/note_model.dart';
import 'package:notes_app/ui/pages/add_note_page.dart';
import 'package:notes_app/ui/styles/colors.dart';
import 'package:notes_app/ui/styles/text_styles.dart';
import 'package:notes_app/ui/styles/textfield_border.dart';
import 'package:notes_app/ui/widgets/icon_button.dart';
import 'package:notes_app/ui/widgets/note_tile.dart';

class HomePage extends StatelessWidget {
  final _notesController = Get.put(NoteController());
  final _tileCounts = [
    [2, 2],
    [2, 2],
    [4, 2],
    [2, 3],
    [2, 2],
    [2, 3],
    [2, 2],
  ];

  final _tileTypes = [
    TileType.Square,
    TileType.Square,
    TileType.HorRect,
    TileType.VerRect,
    TileType.Square,
    TileType.VerRect,
    TileType.Square,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: Obx(
          () =>
              !_notesController.isSearching.value
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton.extended(
                      backgroundColor: const Color.fromARGB(255, 221, 219, 219),
                      onPressed: () {
                        Get.to(
                          const AddNotePage(note: null),
                          transition: Transition.downToUp,
                        );
                      },
                      label: const Text('Add', style: TextStyle(fontSize: 18)),
                      icon: const Icon(Icons.edit),
                    ),
                  )
                  : SizedBox(),
        ),
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [_appBar(), const SizedBox(height: 16), _body()],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        if (!_notesController.isSearching.value) {
          // 🔍 Show title and search icon
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Notes", style: titleTextStyle.copyWith(fontSize: 32)),
              Row(
                children: [
                  MyIconButton(
                    onTap: () {
                      _notesController.isSearching.value = true;
                    },
                    icon: Icons.search,
                  ),
                  const SizedBox(width: 5),
                  PopupMenuButton<Sort>(
                    icon: Icon(
                      Icons.sort,
                      color: Colors.white,
                    ), // only icon shown
                    color: Colors.grey[900],
                    onSelected: (Sort selected) {
                      if (selected == Sort.byTime) {
                        _notesController.sortNotes(true.obs);
                      } else {
                        _notesController.sortNotes(false.obs);
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<Sort>>[
                          const PopupMenuItem<Sort>(
                            value: Sort.byTime,
                            child: Text(
                              "Sort by Time",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem<Sort>(
                            value: Sort.byTitle,
                            enabled: true,
                            child: Text(
                              "Sort by Title",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ],
          );
        } else {
          // ✍️ Show search input and cancel button
          return Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _notesController.txtEditController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Enter Note Title",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: outlineInputBorder,
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    disabledBorder: outlineInputBorder,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _notesController.getNotes();
                    } else {
                      _notesController.searchNotes(value);
                    }
                  },
                  onSubmitted: (value) {
                    if (value.isEmpty) {
                      _notesController.getNotes();
                    } else {
                      _notesController.searchNotes(value);
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  _notesController.isSearching.value = false;
                  // _notesController.txtEditController.clear();
                  _notesController.getNotes();
                  // _notesController.loadSortedNotes(); // Reload full notes list
                },
                child: const Text("Cancel", style: TextStyle(fontSize: 14)),
              ),
            ],
          );
        }
      }),
    );
  }

  _body() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (_notesController.noteList.isNotEmpty) {
            log("Notes List is not empty");
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 10),
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                axisDirection: AxisDirection.down,
                children: [
                  for (int i = 0; i < _notesController.noteList.length; i++)
                    StaggeredGridTile.count(
                      crossAxisCellCount: _tileCounts[i % 7][0],
                      mainAxisCellCount: _tileCounts[i % 7][1],
                      child: Slidable(
                        key: ValueKey(_notesController.noteList[i]),
                        startActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              autoClose: true,

                              onPressed: (context) {
                                _showDialog(
                                  context,
                                  _notesController.noteList[i],
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: NoteTile(
                          index: i,
                          note: _notesController.noteList[i],
                          tileType: _tileTypes[i % 7],
                        ), // Replace with your note display widget
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Center(child: Text("Empty", style: titleTextStyle));
          }
        }),
      ),
    );
  }

  void _showDialog(BuildContext context, Note note) {
    Get.dialog(
      AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Slidable.of(Get.context!)?.close();
              // Slidable.of(context)?.close();
            }, // dismiss without action
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _notesController.temporaryDeleteNote(note);
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(
                  content: Text('Item deleted'),
                  action: SnackBarAction(
                    label: 'undo',
                    onPressed: () {
                      _notesController.getNotes();
                      _notesController.isUndo.value = true;
                    },
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
              if (_notesController.isUndo.value) {
                _notesController.deleteNote(note: note);
              }
              _notesController.isUndo.value = true;
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
