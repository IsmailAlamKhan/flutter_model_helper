import 'dart:io';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';

import 'const.dart';

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

  List<Map<String, dynamic>> list = [];
  final result = [''].obs;
  String fields;
  String modelName;

  final List<Map<String, String>> _listType = [];
  var counter = 0.obs;
  final wantFirestore = false.obs;
  void generateModel() {
    _listType.clear();
    list.clear();
    final _l = fields.replaceAll('\n ', '').replaceAll('; ', ';').split(';');
    List<String> type = [];
    List<String> val = [];
    print(_l);
    _l.forEach((element) {
      if (element.contains(' ')) {
        type.add(element.trim().substring(0, element.indexOf(' ')).trim());
        val.add(element.trim().substring(element.indexOf(' ')).trim());
      }
    });
    type.remove('');
    val.remove('');
    print(type);
    print(val);
    _listType.clear();
    type.forEach((typeElem) {
      val.forEach((valElem) {
        print(_listType.length == val.length);
        if (_listType.length == val.length && _listType.length == type.length)
          return;
        _listType.add({
          'type': typeElem,
          'val': valElem,
        });
      });
    });
    print(_listType);
    list = _listType;

    result.clear();
    if (wantFirestore.value)
      result.add(
          'import ' 'package:cloud_firestore/cloud_firestore.dart' ';\n\n');

    result.add(sprintf('class %sModel{\n', [modelName]));

    result.add('\n///*Fields Start\n');

    list.forEach(
      (element) {
        result.add(
          sprintf(
            '     %s %s;\n',
            [element['type'], element['val']],
          ),
        );
      },
    );
    result.add('\n///*Fields End\n');

    result.add('\n\n///*Constructor Start\n');

    result.add(sprintf('%sModel({\n', [modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            '   this.%s,\n',
            [element['val']],
          ),
        );
      },
    );
    result.add('});');

    result.add('\n\n///*Constructor End\n');

    result.add('\n\n///*To String Start\n');

    result.add(sprintf(ToStringHead, [modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            ToStrMiddle,
            [element['val'], element['val']],
          ),
        );
      },
    );
    result.add('        }\'\'\';\n}');

    result.add('\n\n///*To String End \n');

    if (wantFirestore.value) {
      result.add('\n\n///*fromDocumentSnapshot Start\n');

      result.add(sprintf(FromDocumentSnapshotHead, [modelName]));
      list.forEach(
        (element) {
          if (element['val'] != 'id')
            result.add(
              sprintf(
                FromDocumentSnapshotMiddle,
                [element['val'], element['val']],
              ),
            );
          else
            result.add(
              sprintf(
                FromDocumentSnapshotMiddleID,
                [element['val'], element['val']],
              ),
            );
        },
      );
      result.add('}');

      result.add('\n\n///*fromDocumentSnapshot End \n');
    }
    result.add('\n\n///*From JSON Start \n');

    ///*From Json
    result.add(sprintf(FromJSONHead, [modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            FromJSONMiddle,
            [element['val'], element['val']],
          ),
        );
      },
    );

    result.add('\n  }');

    result.add('\n\n///*From JSON End \n');

    ///*From Json

    result.add('\n\n///*To JSON Start \n');

    ///*To Json
    result.add(sprintf(ToJSONHead, [modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            ToJSONMiddle,
            [element['val'], element['val']],
          ),
        );
      },
    );
    result.add('return data;');
    result.add('\n  }');

    result.add('\n\n///*To JSON End \n');

    ///*To Json
    result.insert(result.length, '}');
    if (wantFirestore.value) {
      genCRUD();
      counter++;
    } else {
      crudResult.clear();
      crudResult.add('No value as you did not choose firebase');
    }
    counter++;
  }

  final crudResult = [''].obs;

  void genCRUD() {
    crudResult.clear();
    crudResult
        .add('import ' 'package:cloud_firestore/cloud_firestore.dart' ';\n\n');

    crudResult.add(
      sprintf(
        'class %sCRUD{\n  final FirebaseFirestore _firestore = FirebaseFirestore.instance;\n',
        [modelName],
      ),
    );

    crudResult.add('\n');

    crudResult.add('  ///*Stream Start\n');

    crudResult.add(sprintf(StreamHead, [modelName, modelName]));
    crudResult.add(
      sprintf(
        StreamMIddle,
        [
          modelName.toLowerCase(),
          modelName,
          modelName,
        ],
      ),
    );

    crudResult.add('\n }\n');

    crudResult.add('  ///*Stream End\n');
    crudResult.add('\n');

    crudResult.add('  ///*Add Start\n');

    crudResult.add(
      sprintf(
        AddHead,
        [
          modelName[0].toUpperCase() + modelName.substring(1),
          modelName,
          modelName
        ],
      ),
    );
    crudResult.add(
      sprintf(
        AddMIddle,
        [modelName],
      ),
    );
    list.forEach((element) {
      crudResult.add(
        sprintf(
          '\n     \'%s\' : \'$modelName.%s\'',
          [
            element['val'],
            element['val'],
          ],
        ),
      );
    });
    crudResult.add(AddEnd);

    crudResult.add('\n }\n');

    crudResult.add('  ///*Add End\n');
    crudResult.add('\n');

    crudResult.add('  ///*Update Start\n');

    crudResult.add(
      sprintf(
        UpdateHead,
        [
          modelName[0].toUpperCase() + modelName.substring(1),
          modelName,
          modelName.toLowerCase()
        ],
      ),
    );
    crudResult.add(
      sprintf(
        UpdateMIddle,
        [
          modelName.toLowerCase(),
          modelName.toLowerCase(),
        ],
      ),
    );
    list.forEach((element) {
      crudResult.add(
        sprintf(
          '\n    ' '%s' ': ${modelName.toLowerCase()}.%s',
          [
            element['val'],
            element['val'],
          ],
        ),
      );
    });
    crudResult.add(UpdateEnd);

    crudResult.add('\n }\n');

    crudResult.add('  ///*Update End\n');
    crudResult.add('\n');

    crudResult.add('  ///*delete Start\n');

    crudResult.add(
      sprintf(
        Delete,
        [
          modelName[0].toUpperCase() + modelName.substring(1),
          modelName,
        ],
      ),
    );

    crudResult.add('  ///*Update End\n');

    crudResult.add('\n');

    crudResult.insert(crudResult.length, '}');
    counter++;
  }

  void genCode(BuildContext context) {
    final snackBar = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    if (modelName == null || modelName == '') {
      snackBar.hideCurrentSnackBar();
      snackBar.showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the name of the model',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
      FocusScope.of(Get.context).requestFocus(modelNameFocus);
      return;
    }
    if (fields == null || fields == '') {
      snackBar.hideCurrentSnackBar();
      snackBar.showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the fields of the model',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
      FocusScope.of(Get.context).requestFocus(modelFieldsFocus);
      return;
    }
    snackBar.hideCurrentSnackBar();
    generateModel();

    /*
    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) => ScaleTransition(
        scale: animation,
        child: _buildDialog(theme, context),
      ),
    );
    */
  }

/*
  Widget _buildDialog(ThemeData theme, BuildContext context) {
    return RawKeyboardListener(
      focusNode: keyBoardFocus,
      autofocus: true,
      onKey: (RawKeyEvent key) {
        if (key.runtimeType.toString() == 'RawKeyDownEvent') {
          String _key = key.data.keyLabel;
          print(_key);
          if (_key == 'Y' || _key == 'y') _genCode(true);
          if (_key == 'N' || _key == 'n') _genCode(false);
        }
      },
      child: AlertDialog(
        title: Text(
          'Do you want Firebase?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            child: Text('Yes'),
            style: ElevatedButton.styleFrom(
              primary: theme.accentColor,
            ),
            onPressed: () => _genCode(true),
          ),
          ElevatedButton(
            child: Text('No'),
            style: ElevatedButton.styleFrom(
              primary: theme.accentColor,
            ),
            onPressed: () => _genCode(false),
          ),
          ElevatedButton(
            child: Text('Cancel'),
            style: ElevatedButton.styleFrom(
              primary: theme.disabledColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _genCode() {
    Get.back();
    generateModel();
  }
*/
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
