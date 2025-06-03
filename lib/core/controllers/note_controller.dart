import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:notes_app/core/db/db_helper.dart';
import 'package:notes_app/core/models/note_model.dart';

class NoteController extends GetxController {
  final TextEditingController txtEditController = TextEditingController();
  RxBool isSearching = false.obs;
  RxBool isSorting = false.obs;
  RxBool isUndo = false.obs;
  RxList<Note> noteList = <Note>[].obs;
  Note? recentDeletedNote;

  @override
  void onReady() {
    getNotes();
    super.onReady();
  }

  Future<void> addNote({required Note note}) async {
    try {
      await DBHelper.insert(note);
    } catch (e) {
      log('Exception (notController): $e');
    }
    getNotes();
  }

  Future<void> getNotes() async {
    List<Map<String, dynamic>> notes = await DBHelper.query();
    noteList.assignAll(notes.map((data) => Note.fromJson(data)).toList());
  }

  void temporaryDeleteNote(Note note) {
    recentDeletedNote = note;
    noteList.removeWhere((not) => not.id == note.id);
  }

  Future<void> deleteNote({required Note note}) async {
    await DBHelper.delete(note);
    getNotes();
  }

  Future<void> updateNote({required Note note}) async {
    await DBHelper.update(note);
    getNotes();
  }

  Future<void> searchNotes(String title) async {
    log("Search  Working");
    try {
      var result = await DBHelper.searchNotesByTitle(
        title.trim().toLowerCase(),
      );
      noteList.assignAll(result);
    } catch (e) {
      log("Error is $e");
    }
  }

  Future<void> sortNotes(RxBool isSortByDate) async {
    try {
      var result = await DBHelper.sortNotes(sortByDate: isSortByDate.value);
      noteList.assignAll(result);
    } catch (e) {
      log("Error in Sorting $e");
    }
  }
}
