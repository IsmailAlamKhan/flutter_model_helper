import 'dart:convert';
import 'dart:io';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:model_help/const.dart';
import 'ext.dart';
import 'package:path/path.dart' as path;

class ModelController extends GetxService with SingleGetTickerProviderMixin {
  TabController tabController;
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
  }

  final FocusNode keyBoardFocus = FocusNode();
  final FocusNode modelNameFocus = FocusNode();
  final FocusNode modelFieldsFocus = FocusNode();

  var counter = 0.obs;
  final wantFirestore = false.obs;
  final _result = ''.obs;
  String get result => _result.value;

  void getModel() {}

  Future<void> openJSON() async {
    final file_chooser.FileChooserResult result =
        await file_chooser.showOpenPanel(
      allowedFileTypes: [
        file_chooser.FileTypeFilterGroup(
          fileExtensions: ['json'],
          label: 'json',
        ),
      ],
    );
    final _file = File(result.paths.first);
    final String fileContains = await _file.readAsString();
    final Map<String, dynamic> json = jsonDecode(fileContains);
    final _name = path.basename(_file.path);
    List<String> _fields = <String>[];
    List<String> _types = <String>[];
    final _modelName =
        '${_name.substring(0, _name.indexOf('.')).replaceAll('_', ' ').capitalize.replaceAll(' ', '')}';

    for (var item in json.keys) {
      _fields.add(item);
      if (json[item] is Map<String, dynamic>) {
        _types.add(item.capitalize);
      } else {
        _types.add(json[item].runtimeType.toString());
      }
    }

    ///*Model Start
    _result("$_modelName{\n");

    ///*Model FIELDS Declare
    for (var i = 0; i < _fields.length; i++) {
      _result.value += '$ONETAB${_types[i]} ${_fields[i]};\n';
    }

    ///*Model Constructor
    _result.value += '\n$ONETAB$_modelName({\n';
    for (var i = 0; i < _fields.length; i++) {
      _result.value += '${TWOTAB}this.${_fields[i]},\n';
    }

    _result.value += '$ONETAB)}\n\n';

    ///*Firestore
    if (wantFirestore.value) {
      _result.value +=
          '$ONETAB$_modelName.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {\n';
      _result.value += '${THREETAB}id = documentSnapshot.id\n';

      for (var i = 0; i < _fields.length; i++) {
        _result.value +=
            '$THREETAB${_fields[i]} = documentSnapshot.data()[\'${_fields[i]}\'],\n';
      }
      _result.value += '$ONETAB}';
    }

    ///*End
    _result.value += '\n}';
  }

  Future<void> saveAsDart({String modelContents, String modelName}) async {
    final result = await file_chooser.showSavePanel(
      suggestedFileName: '${modelName.toLowerCase()}.dart',
      allowedFileTypes: const [
        file_chooser.FileTypeFilterGroup(
          label: 'dart',
          fileExtensions: ['dart'],
        )
      ],
    );
    if (!result.canceled) {
      await File(result.paths[0]).writeAsString(modelContents);
    }
  }

  Future<String> get pasteFromClipBoard async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }
}
