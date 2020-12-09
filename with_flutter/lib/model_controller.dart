import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';

class ModelController extends GetxService {
  final FocusNode keyBoardFocus = FocusNode();
  final FocusNode modelNameFocus = FocusNode();
  final FocusNode modelFieldsFocus = FocusNode();

  final String fromJSONHead = ' %s.fromJson(Map<String, dynamic> json) {';
  final String fromJSONMiddle = '\n     %s = json[' '%s' '];';

  final String toJSONHead =
      ' Map<String, dynamic> toJson() {\nfinal Map<String, dynamic> data = Map<String, dynamic>();';
  final String toJSONMiddle = '\n     data[' '%s' '] = this.%s;';
  final String toStringHead = '@override\n'
      ' String toString() {\n'
      ' return '
      '\'\'\' '
      '%s:{\n';

  final String toStrMiddle = '            %s = \${this.%s};' '\n';
  final String fromDocumentSnapshotHead =
      '%s.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {\n';

  final String fromDocumentSnapshotMiddleID =
      r'            %s = documentSnapshot.%s;' '\n';
  final String fromDocumentSnapshotMiddle =
      r'            %s = documentSnapshot.data()[' '%s' '];' '\n';
  List<Map<String, dynamic>> list = List<Map<String, dynamic>>();
  List<String> result = [''];
  String fields;
  String modelName;

  final List<Map<String, dynamic>> _listType = List<Map<String, dynamic>>();
  var counter = 0.obs;
  void generateModel(bool wantFirestore) {
    _listType.clear();
    list.clear();
    final _l = fields.replaceAll('\n ', '').replaceAll('; ', ';').split(';');
    List<String> type = List<String>();
    List<String> val = List<String>();
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

    type.forEach((type) {
      val.forEach((val) {
        if (!_listType.contains(type) && !_listType.contains(val))
          _listType.add({
            'type': type,
            'val': val,
          });
      });
    });
    print(_listType);
    list = _listType;

    result.clear();
    if (wantFirestore)
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

    result.add(sprintf(toStringHead, [modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            toStrMiddle,
            [element['val'], element['val']],
          ),
        );
      },
    );
    result.add('        }\'\'\';\n}');

    result.add('\n\n///*To String End \n');

    if (wantFirestore) {
      result.add('\n\n///*fromDocumentSnapshot Start\n');

      result.add(sprintf(fromDocumentSnapshotHead, [modelName]));
      list.forEach(
        (element) {
          if (element['val'] != 'id')
            result.add(
              sprintf(
                fromDocumentSnapshotMiddle,
                [element['val'], element['val']],
              ),
            );
          else
            result.add(
              sprintf(
                fromDocumentSnapshotMiddleID,
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
    result.add(sprintf(fromJSONHead, [modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            fromJSONMiddle,
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
    result.add(sprintf(toJSONHead, [modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            toJSONMiddle,
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
    if (wantFirestore)
      genModel();
    else
      crudResult.add('No value as you did not choose firebase');
    counter++;
  }

  final crudResult = [''];
  final String streamHead = ' Stream<List<%s>> %sStream() {';
  final String streamMIddle = '\n    return _firestore'
      '\n     .collection('
      '%s'
      ')'
      '\n     .snapshots()'
      '\n     .map((QuerySnapshot query) {'
      '\n       List<%s> retVal = List();'
      '\n        query.docs.forEach((element) async {'
      '\n          retVal.add('
      '\n            %s.fromDocumentSnapshot('
      '\n              documentSnapshot: element,'
      '\n            ),'
      '\n          );'
      '\n       });'
      '\n     return retVal;'
      '\n   });';

  final String addHead = ' void add%s({%s %s}) {';
  final String addMIddle = '\n  _firestore'
      '\n    .collection('
      '%s'
      ').doc().set({'
      '\n    '
      'dateCreated'
      ': Timestamp.now(),';
  final String addEnd = '\n    })'
      '\n    .then((value) => print('
      'success'
      '))'
      '\n    .catchError((err) {'
      '\n        print(err.message);'
      '\n        print(err.code);'
      '\n      });'
      '\n    }';
  final String updateHead = ' void update%s({%s %s}) {';
  final String updateMIddle = '\n  _firestore'
      '\n    .collection('
      '%s'
      ').doc(%s.id).update({'
      '\n    '
      'dateCreated'
      ': Timestamp.now(),';
  final String updateEnd = '\n    })'
      '\n    .then((value) => print('
      'success'
      '))'
      '\n    .catchError((err) {'
      '\n        print(err.message);'
      '\n        print(err.code);'
      '\n      });'
      '\n    }';

  final String delete = ' void delete%s({int id}) {'
      '\n  _firestore'
      '\n    .collection('
      '%s'
      ').doc(id).delete()'
      '\n    .then((value) => print('
      'success'
      '))'
      '\n    .catchError((err) {'
      '\n        print(err.message);'
      '\n        print(err.code);'
      '\n      });'
      '\n    }';

  void genModel() {
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

    crudResult.add(sprintf(streamHead, [modelName, modelName]));
    crudResult.add(
      sprintf(
        streamMIddle,
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
        addHead,
        [
          modelName[0].toUpperCase() + modelName.substring(1),
          modelName,
          modelName
        ],
      ),
    );
    crudResult.add(
      sprintf(
        addMIddle,
        [modelName],
      ),
    );
    list.forEach((element) {
      crudResult.add(
        sprintf(
          '\n    ' '%s' ': $modelName.%s',
          [
            element['val'],
            element['val'],
          ],
        ),
      );
    });
    crudResult.add(addEnd);

    crudResult.add('\n }\n');

    crudResult.add('  ///*Add End\n');
    crudResult.add('\n');

    crudResult.add('  ///*Update Start\n');

    crudResult.add(
      sprintf(
        updateHead,
        [
          modelName[0].toUpperCase() + modelName.substring(1),
          modelName,
          modelName.toLowerCase()
        ],
      ),
    );
    crudResult.add(
      sprintf(
        updateMIddle,
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
    crudResult.add(updateEnd);

    crudResult.add('\n }\n');

    crudResult.add('  ///*Update End\n');
    crudResult.add('\n');

    crudResult.add('  ///*delete Start\n');

    crudResult.add(
      sprintf(
        delete,
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
    snackBar.hideCurrentSnackBar();

    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) => ScaleTransition(
        scale: animation,
        child: _buildDialog(theme, context),
      ),
    );
  }

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

  void _genCode(bool wantFirebase) {
    Get.back();
    generateModel(wantFirebase);
  }
}
