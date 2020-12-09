import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dart_code_viewer/dart_code_viewer.dart';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:model_help/model_controller.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Model Helper',
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
      home: MyHomePage(title: 'Flutter Model Helper'),
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
  TabController tabController;
  ModelController controller;
  @override
  void initState() {
    super.initState();

    tabController = TabController(vsync: this, length: 2);
    controller = Get.put(ModelController());
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
              tooltip: 'Save as Dart',
              onPressed: () async {
                if (controller.result.join() == '' ||
                    controller.result.join() == null)
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
                await saveAsDart(
                  modelContents: tabController.index == 0
                      ? controller.result.join()
                      : controller.crudResult.join(),
                  modelName: tabController.index == 0
                      ? '${controller.modelName}_model'
                      : '${controller.modelName}_crud',
                );
              },
            ),
          ],
        ),
        body: Obx(
          () {
            controller.counter.value;
            return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constrains) {
              if (constrains.maxWidth >= 700)
                return Row(
                  children: [
                    Container(
                      width: deviceSize.width / 2,
                      height: deviceSize.height - kToolbarHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          right:
                              BorderSide(color: theme.dividerColor, width: 2),
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
                          bottom:
                              BorderSide(color: theme.dividerColor, width: 2),
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
            });
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => controller.genCode(context),
          tooltip: 'Generate Model',
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

  Widget _buildGeneratedCode(bool isCRUD) {
    return CupertinoScrollbar(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
        ),
        child: DartCodeViewer.flutterInteract19(
          !isCRUD ? controller.result.join() : controller.crudResult.join(),
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
            focusNode: controller.modelNameFocus,
            controller: modelNameTEC,
            onChanged: (val) => controller.modelName = val.trim(),
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
              controller.fields = val;
            },
            controller: modelFieldsTEC,
            decoration: InputDecoration(
              labelText: 'Insert the fields of your model',
              helperText: "Separate the fields using semicolon( ';' )",
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

Future<String> get getClipBoardData async {
  ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
  return data.text;
}
