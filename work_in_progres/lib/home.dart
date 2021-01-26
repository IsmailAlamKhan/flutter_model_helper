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
                await controller.saveAsDart(
                  context,
                );
              },
            ),
          ],
        ),
        body: _buildCode(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            return controller.openJSON(context);
          },
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
            controller.result,
          ),
        ),
      ),
    );
  }
}