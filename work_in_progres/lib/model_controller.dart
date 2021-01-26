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

  String modelName = '';
  final isLoading = false.obs;
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
          Obx(
            () => TextButton(
              onPressed: isLoading.value
                  ? null
                  : () {
                      isLoading(true);
                      switch (_isLocal.value) {
                        case 0:
                          _openLocalJson();
                          break;
                        case 1:
                          if (!_formKey.currentState.validate()) {
                            isLoading(false);
                            return;
                          }
                          _openRemoteJson(apiURL, context);
                          break;
                      }
                    },
              child: AnimatedSwitcher(
                duration: 500.milliseconds,
                child: isLoading.value
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Text('Generate'),
              ),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: isLoading.value ? null : () => Get.back(),
              child: Text('Cancel'),
            ),
          ),
        ],
        scrollable: true,
        content: Obx(
          () => Container(
            width: 400,
            child: Column(
              children: [
                RadioListTile<int>(
                  title: Text('Local'),
                  groupValue: _isLocal.value,
                  onChanged: (int val) => _isLocal(val),
                  value: 0,
                  toggleable: true,
                  activeColor: context.theme.accentColor,
                ),
                RadioListTile<int>(
                  title: Text('Remote'),
                  groupValue: _isLocal.value,
                  toggleable: true,
                  onChanged: (int val) => _isLocal(val),
                  value: 1,
                  activeColor: context.theme.accentColor,
                ),
                AnimatedSwitcher(
                  duration: 500.milliseconds,
                  transitionBuilder: (child, animation) => SizeTransition(
                    child: ClipRRect(child: child),
                    axis: Axis.vertical,
                    axisAlignment: 1.0,
                    sizeFactor: animation,
                  ),
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
                                  } else if (!value.isURL) {
                                    return 'Please write a valid URL';
                                  }
                                  return null;
                                },
                                onChanged: (val) => apiURL = val,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Model name',
                                ),
                                validator: (value) {
                                  if (value == '') {
                                    return 'Please the Model name';
                                  }
                                  return null;
                                },
                                onChanged: (val) => modelName = val,
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

  final GetConnect connect = GetConnect();

  Future<void> _openRemoteJson(String url, BuildContext context) async {
    try {
      final Response _res = await connect.get(url);

      Get.back();
      print(_res.body.runtimeType);
      if (!(_res.body is Map<String, dynamic>) &&
          !(_res.body is List<dynamic>)) {
        isLoading(false);
        Get.rawSnackbar(
          margin: EdgeInsets.zero,
          message: 'The url doesn\'t have a valid json response',
          backgroundColor: context.theme.errorColor,
        );
        return;
      }
      if (_res.body is List<dynamic>) {
        await _convertJSON(jsonEncode(_res.body.first));
      } else {
        await _convertJSON(jsonEncode(_res.body));
      }
    } catch (e) {
      isLoading(false);
      Get.back();
      Get.rawSnackbar(
        margin: EdgeInsets.zero,
        message: e.toString(),
        backgroundColor: context.theme.errorColor,
      );
      rethrow;
    }
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
    modelName =
        '${path.basename(_file.path).substring(0, path.basename(_file.path).indexOf('.')).capitalize.replaceAll(' ', '').replaceAll('_', '')}';

    Get.back();
    await _convertJSON(
      fileContains,
    );
  }

  Future<void> _convertJSON(String data) async {
    final Map<String, dynamic> json = jsonDecode(data);
    List<String> _fields = <String>[];
    List<String> _types = <String>[];

    for (var item in json.keys) {
      _fields.add(item);
      if (json[item] is Map<String, dynamic>) {
        _types.add(item.capitalize);
      } else {
        _types.add(json[item].runtimeType.toString());
      }
    }

    ///*Model Start
    _result("$modelName{\n");

    ///*Model FIELDS Declare
    for (var i = 0; i < _fields.length; i++) {
      _result.value += '$ONETAB${_types[i]} ${_fields[i]};\n';
    }

    ///*Model Constructor
    _result.value += '\n$ONETAB$modelName({\n';
    for (var i = 0; i < _fields.length; i++) {
      _result.value += '${TWOTAB}this.${_fields[i]},\n';
    }

    _result.value += '$ONETAB)}';

    ///*Firestore
    if (wantFirestore.value) {
      _result.value +=
          '\n$ONETAB$modelName.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {\n';
      _result.value += '${THREETAB}id = documentSnapshot.id\n';

      for (var i = 0; i < _fields.length; i++) {
        _result.value +=
            '$THREETAB${_fields[i]} = documentSnapshot.data()[\'${_fields[i]}\'],\n';
      }
      _result.value += '$ONETAB}';
    }

    ///*End
    _result.value += '\n}';
    isLoading(false);
  }

  Future<void> saveAsDart(BuildContext context) async {
    if (result == '' || result == null)
      return Get.rawSnackbar(
        margin: EdgeInsets.zero,
        message: 'Generate a model first',
        backgroundColor: context.theme.errorColor,
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