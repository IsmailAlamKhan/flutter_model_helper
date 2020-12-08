import 'dart:convert';
import "dart:io";
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:google_fonts/google_fonts.dart';
import "package:sprintf/sprintf.dart";
import "package:dart_code_viewer/dart_code_viewer.dart";
import "package:file_chooser/file_chooser.dart" as file_chooser;

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Model Helper",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        // primaryColor: Color(0xFF8BE9FD),
        accentColor: Color(0xFFffa65c),
        textTheme: GoogleFonts.poppinsTextTheme(),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF241e30),
        appBarTheme: AppBarTheme(
          elevation: 6,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: MyHomePage(title: "Flutter Model Helper"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final TextEditingController modelNameTEC = TextEditingController();
  final TextEditingController modelFieldsTEC = TextEditingController();
  final FocusNode keyBoardFocus = FocusNode();
  final FocusNode modelNameFocus = FocusNode();
  final FocusNode modelFieldsFocus = FocusNode();
  TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            widget.title,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              tooltip: "Save as Dart",
              onPressed: () async {
                if (result.join() == '' || result.join() == null)
                  return ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Generate a Model First",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.red[900],
                    ),
                  );
                await saveAsDart(
                  modelContents: tabController.index == 0
                      ? result.join()
                      : crudResult.join(),
                  modelName: tabController.index == 0
                      ? "${_modelName}_model"
                      : "${_modelName}_crud",
                );
              },
            ),
          ],
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constrains) {
          if (constrains.maxWidth >= 700)
            return Row(
              children: [
                Container(
                  width: deviceSize.width / 2,
                  height: deviceSize.height - kToolbarHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: theme.dividerColor, width: 2),
                    ),
                  ),
                  child: _buildCode(),
                ),
                Container(
                  width: (deviceSize.width) / 2,
                  height: deviceSize.height,
                  child: _buildInputs(modelNameTEC, modelFieldsTEC),
                ),
              ],
            );
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  width: deviceSize.width,
                  height: (deviceSize.height - kToolbarHeight) / 2,
                  child: _buildCode(),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor, width: 2),
                    ),
                  ),
                ),
              ),
              Container(
                width: deviceSize.width,
                height: (deviceSize.height - kToolbarHeight - 100) / 2,
                child: _buildInputs(modelNameTEC, modelFieldsTEC),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => genCode(),
          tooltip: "Generate Model",
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCode() {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: [
            Tab(
              text: 'Model',
            ),
            Tab(
              text: 'CRUD',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildGeneratedCode(false),
              _buildGeneratedCode(true),
            ],
          ),
        ),
      ],
    );
  }

  void genCode() {
    final snackBar = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    if (_modelName == null || _modelName == '') {
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
      FocusScope.of(context).requestFocus(modelNameFocus);
      return;
    }
    snackBar.hideCurrentSnackBar();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
      },
    );
  }

  void _genCode(bool wantFirebase) {
    Navigator.of(context).pop();
    generateModel(wantFirebase);
  }

  Widget _buildGeneratedCode(bool isCRUD) {
    return CupertinoScrollbar(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
        ),
        child: DartCodeViewer.flutterInteract19(
          !isCRUD ? result.join() : crudResult.join(),
        ),
      ),
    );
  }

  Widget _buildInputs(
    TextEditingController modelNameTEC,
    TextEditingController modelFieldsTEC,
  ) {
    return CupertinoScrollbar(
      controller: scrollController,
      isAlwaysShown: true,
      thickness: 10,
      thicknessWhileDragging: 12,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            focusNode: modelNameFocus,
            controller: modelNameTEC,
            onChanged: (val) => _modelName = val.trim(),
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              labelText: 'Name of your model',
              suffixIcon: IconButton(
                icon: Icon(Icons.paste),
                onPressed: () async {
                  modelNameTEC.text = await getClipBoardData;
                },
              ),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            style: TextStyle(
              color: Colors.white,
            ),
            onChanged: (val) {
              _fields = val;
            },
            controller: modelFieldsTEC,
            decoration: InputDecoration(
              labelText: 'Insert the fields of your model',
              helperText: 'Separate the fields using semicolon( ";" )',
              suffixIcon: IconButton(
                icon: Icon(Icons.paste),
                onPressed: () async {
                  modelFieldsTEC.text = await getClipBoardData;
                },
              ),
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: null,
          ),
        ],
      ),
    );
  }

  final String fromJSONHead = " %s.fromJson(Map<String, dynamic> json) {";
  final String fromJSONMiddle = "\n     %s = json['%s'];";

  final String toJSONHead =
      " Map<String, dynamic> toJson() {\nfinal Map<String, dynamic> data = Map<String, dynamic>();";
  final String toJSONMiddle = "\n     data['%s'] = this.%s;";
  final String toStringHead = "@override\n"
      " String toString() {\n"
      " return "
      "'''%s:{\n";

  final String toStrMiddle = r"            %s = ${this.%s};" "\n";
  final String fromDocumentSnapshotHead =
      '%s.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {\n';

  final String fromDocumentSnapshotMiddleID =
      r"            %s = documentSnapshot.%s;" "\n";
  final String fromDocumentSnapshotMiddle =
      r"            %s = documentSnapshot.data()['%s'];" "\n";
  List<Map<String, dynamic>> list = List<Map<String, dynamic>>();
  List<String> result = [""];
  String _fields;
  String _modelName;

  void generateModel(bool wantFirestore) {
    final _l = _fields.replaceAll('\n', '').split(';');
    List<String> type = List<String>();
    List<String> val = List<String>();
    _l.forEach((element) {
      if (element.contains(' ')) {
        type.add("'type':${element.substring(0, element.indexOf(' ')).trim()}");
        val.add("'val':${element.substring(element.indexOf(' ')).trim()}");
      }
      // print(element.substring(0, element.indexOf(' ')).trim());
    });
    final _list = List<String>();
    _list.addAll([...type, ...val]);
    list = jsonDecode(jsonEncode(_list)) as List<Map<String, dynamic>>;

    result.clear();
    if (wantFirestore)
      result.add("import 'package:cloud_firestore/cloud_firestore.dart';\n\n");

    result.add(sprintf("class %sModel{\n", [_modelName]));

    result.add("\n///*Fields Start\n");

    list.forEach(
      (element) {
        result.add(
          sprintf(
            "     %s %s;\n",
            [element['type'], element['val']],
          ),
        );
      },
    );
    result.add("\n///*Fields End\n");

    result.add("\n\n///*Constructor Start\n");

    result.add(sprintf("%sModel({\n", [_modelName]));
    list.forEach(
      (element) {
        result.add(
          sprintf(
            "   this.%s,\n",
            [element['val']],
          ),
        );
      },
    );
    result.add("});");

    result.add("\n\n///*Constructor End\n");

    result.add("\n\n///*To String Start\n");

    result.add(sprintf(toStringHead, [_modelName]));
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
    result.add("        }''';\n}");

    result.add("\n\n///*To String End \n");
    if (wantFirestore) {
      result.add("\n\n///*fromDocumentSnapshot Start\n");

      result.add(sprintf(fromDocumentSnapshotHead, [_modelName]));
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
      result.add("}");

      result.add("\n\n///*fromDocumentSnapshot End \n");
    }
    result.add("\n\n///*From JSON Start \n");

    ///*From Json
    result.add(sprintf(fromJSONHead, [_modelName]));
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

    result.add("\n\n///*From JSON End \n");

    ///*From Json

    result.add("\n\n///*To JSON Start \n");

    ///*To Json
    result.add(sprintf(toJSONHead, [_modelName]));
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

    result.add("\n\n///*To JSON End \n");

    ///*To Json
    result.insert(result.length, "}");
    setState(() {});
    if (wantFirestore)
      genModel();
    else
      crudResult.add('No value as you did not choose firebase');
  }

  final crudResult = [''];
  final String streamHead = ' Stream<List<%s>> %sStream() {';
  final String streamMIddle = "\n    return _firestore"
      "\n     .collection('%s')"
      "\n     .snapshots()"
      "\n     .map((QuerySnapshot query) {"
      "\n       List<%s> retVal = List();"
      "\n        query.docs.forEach((element) async {"
      "\n          retVal.add("
      "\n            %s.fromDocumentSnapshot("
      "\n              documentSnapshot: element,"
      "\n            ),"
      "\n          );"
      "\n       });"
      "\n     return retVal;"
      "\n   });";

  final String addHead = ' void add%s({%s %s}) {';
  final String addMIddle = "\n  _firestore"
      "\n    .collection('%s').doc().set({"
      "\n    'dateCreated': Timestamp.now(),";
  final String addEnd = "\n    })"
      "\n    .then((value) => print('success'))"
      "\n    .catchError((err) {"
      "\n        print(err.message);"
      "\n        print(err.code);"
      "\n      });"
      "\n    }";
  final String updateHead = ' void update%s({%s %s}) {';
  final String updateMIddle = "\n  _firestore"
      "\n    .collection('%s').doc(%s.id).update({"
      "\n    'dateCreated': Timestamp.now(),";
  final String updateEnd = "\n    })"
      "\n    .then((value) => print('success'))"
      "\n    .catchError((err) {"
      "\n        print(err.message);"
      "\n        print(err.code);"
      "\n      });"
      "\n    }";

  final String delete = " void delete%s({int id}) {"
      "\n  _firestore"
      "\n    .collection('%s').doc(id).delete()"
      "\n    .then((value) => print('success'))"
      "\n    .catchError((err) {"
      "\n        print(err.message);"
      "\n        print(err.code);"
      "\n      });"
      "\n    }";

  void genModel() {
    crudResult.clear();
    crudResult
        .add("import 'package:cloud_firestore/cloud_firestore.dart';\n\n");

    crudResult.add(
      sprintf(
        "class %sCRUD{\n  final FirebaseFirestore _firestore = FirebaseFirestore.instance;\n",
        [_modelName],
      ),
    );

    crudResult.add('\n');

    crudResult.add('  ///*Stream Start\n');

    crudResult.add(sprintf(streamHead, [_modelName, _modelName]));
    crudResult.add(
      sprintf(
        streamMIddle,
        [
          _modelName.toLowerCase(),
          _modelName,
          _modelName,
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
          _modelName[0].toUpperCase() + _modelName.substring(1),
          _modelName,
          _modelName
        ],
      ),
    );
    crudResult.add(
      sprintf(
        addMIddle,
        [_modelName],
      ),
    );
    list.forEach((element) {
      crudResult.add(
        sprintf(
          "\n    '%s': $_modelName.%s",
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
          _modelName[0].toUpperCase() + _modelName.substring(1),
          _modelName,
          _modelName.toLowerCase()
        ],
      ),
    );
    crudResult.add(
      sprintf(
        updateMIddle,
        [
          _modelName.toLowerCase(),
          _modelName.toLowerCase(),
        ],
      ),
    );
    list.forEach((element) {
      crudResult.add(
        sprintf(
          "\n    '%s': ${_modelName.toLowerCase()}.%s",
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
          _modelName[0].toUpperCase() + _modelName.substring(1),
          _modelName,
        ],
      ),
    );

    crudResult.add('  ///*Update End\n');

    crudResult.add('\n');

    crudResult.insert(crudResult.length, '}');

    setState(() {});
  }
}

Future<void> saveAsDart({String modelContents, String modelName}) async {
  final result = await file_chooser.showSavePanel(
    suggestedFileName: "${modelName.toLowerCase()}.dart",
    allowedFileTypes: const [
      file_chooser.FileTypeFilterGroup(
        label: "dart",
        fileExtensions: ["dart"],
      )
    ],
  );
  if (!result.canceled) {
    await File(result.paths[0]).writeAsString(modelContents);
  }
}

Future<String> get getClipBoardData async {
  ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
  return data.text;
}
