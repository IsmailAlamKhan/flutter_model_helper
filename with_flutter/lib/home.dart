import 'package:dart_code_viewer/dart_code_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_help/model_controller.dart';

class Home extends GetView<ModelController> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController modelNameTEC = TextEditingController();
  final TextEditingController modelFieldsTEC = TextEditingController();

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
            "Flutter Model Helper",
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
                await controller.saveAsDart(
                  modelContents: controller.tabController.index == 0
                      ? controller.result.join()
                      : controller.crudResult.join(),
                  modelName: controller.tabController.index == 0
                      ? '${controller.modelName}_model'
                      : '${controller.modelName}_crud',
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
                    alignment: Alignment.centerLeft,
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
          controller: controller.tabController,
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
            controller: controller.tabController,
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
        child: Obx(
          () => DartCodeViewer.flutterInteract19(
            !isCRUD ? controller.result.join() : controller.crudResult.join(),
          ),
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
                  modelNameTEC.text = await controller.pasteFromClipBoard;
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
            focusNode: controller.modelFieldsFocus,
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
                  modelFieldsTEC.text = await controller.pasteFromClipBoard;
                },
              ),
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: null,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                'Do you want Firebase?',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Obx(
                () => Checkbox(
                  checkColor: Get.context.theme.primaryColor,
                  activeColor: Get.context.theme.accentColor,
                  value: controller.wantFirestore.value,
                  onChanged: controller.wantFirestore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
