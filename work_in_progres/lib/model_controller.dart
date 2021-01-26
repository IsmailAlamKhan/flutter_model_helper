import 'dart:convert';
import 'dart:io';

import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:model_help/const.dart';
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
  String modelName = '';

  Future<void> openJSON(BuildContext context) async {
    RxInt _isLocal = 2.obs;
    wantFirestore(false);
    final _formKey = GlobalKey<FormState>();
    String apiURL = '';

    ever(_isLocal, print);
    Get.dialog(
      AlertDialog(
        title: Text('Choose a source'),
        actions: [
          TextButton(
            onPressed: () {
              switch (_isLocal.value) {
                case 0:
                  _openLocalJson();
                  break;
                case 1:
                  if (!_formKey.currentState.validate()) {
                    return;
                  }
                  _openRemoteJson(apiURL);

                  break;
              }
            },
            child: Text('Generate'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
        ],
        scrollable: true,
        content: Obx(
          () => Column(
            children: [
              RadioListTile<int>(
                title: Text('Local'),
                groupValue: _isLocal.value,
                onChanged: (int val) => _isLocal(val),
                value: 0,
                toggleable: true,
              ),
              RadioListTile<int>(
                title: Text('Remote'),
                groupValue: _isLocal.value,
                toggleable: true,
                onChanged: (int val) => _isLocal(val),
                value: 1,
              ),
              AnimatedSwitcher(
                duration: 500.milliseconds,
                child: _isLocal.value == 1
                    ? Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'URL',
                              ),
                              validator: (value) {
                                if (value == '') {
                                  return 'Please write the URL';
                                } else if (!value.contains('http://')) {
                                  return 'Please write a valid URL';
                                }
                                return null;
                              },
                              onChanged: (val) => apiURL = val,
                            ),
                          ],
                        ),
                      )
                    : _isLocal.value == 0
                        ? Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              _wantFirebase(context),
                            ],
                          )
                        : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _wantFirebase(BuildContext context) {
    return Row(
      children: [
        Text(
          'Do you want Firebase?',
          style: context.textTheme.subtitle1,
        ),
        Obx(
          () => Checkbox(
            checkColor: context.theme.primaryColor,
            activeColor: context.theme.accentColor,
            value: wantFirestore.value,
            onChanged: wantFirestore,
          ),
        ),
      ],
    );
  }

  Future<void> _openRemoteJson(String modelName) async {
    Get.back();
    Get.snackbar('Error', 'Not yet implemeted');
  }

  Future<void> _openLocalJson() async {
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
    _convertJSON(
      path.basename(_file.path),
      fileContains,
    );
    Get.back();
  }

  Future<void> _convertJSON(
    String name,
    String data,
  ) async {
    final Map<String, dynamic> json = jsonDecode(data);
    final _name = name;
    List<String> _fields = <String>[];
    List<String> _types = <String>[];
    modelName =
        '${_name.substring(0, _name.indexOf('.')).capitalize.replaceAll(' ', '')}';
    final _modelName = _name
        .substring(0, _name.indexOf('.'))
        .replaceAll('_', ' ')
        .capitalize
        .replaceAll(' ', '');

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

    _result.value += '$ONETAB)}';

    ///*Firestore
    if (wantFirestore.value) {
      _result.value +=
          '\n$ONETAB$_modelName.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {\n';
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

  Future<void> saveAsDart(BuildContext context) async {
    if (result == '' || result == null)
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Generate a Model First',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
    final _result = await file_chooser.showSavePanel(
      suggestedFileName: '${modelName.toLowerCase()}_model.dart',
      allowedFileTypes: const [
        file_chooser.FileTypeFilterGroup(
          label: 'dart',
          fileExtensions: ['dart'],
        )
      ],
    );
    if (!_result.canceled) {
      await File(_result.paths[0]).writeAsString(result);
    }
  }

  Future<String> get pasteFromClipBoard async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }
}