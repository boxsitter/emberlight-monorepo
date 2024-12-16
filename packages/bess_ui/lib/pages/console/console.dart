import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';
import '../../logic/controllers/console_controller.dart';

class ConsoleScreen extends StatelessWidget {
  const ConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: ConsoleScreenDesktop());
  }
}

class ConsoleScreenDesktop extends StatelessWidget {
  ConsoleScreenDesktop({super.key});

  final ConsoleController consoleController = Get.find<ConsoleController>();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1000,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make the column take minimum height
            children: [

              // Display logs in a scrollable area
              Expanded(
                child: Obx(
                      () => ListView.builder(
                    reverse: true, // Ensure new logs appear at the bottom.
                    itemCount: consoleController.logs.length,
                    itemBuilder: (context, index) {
                      final log = consoleController.logs.reversed.toList()[index];
                      final logType = log['type']; // Access log type.
                      final message = log['message']; // Access log message.
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          message!,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 14.0,
                            color: logType == 'user' ? Colors.greenAccent : Colors.blueAccent, // Different colors for user and system.
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )

            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: textFieldFocusNode,
                controller: textEditingController,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText: 'Enter command',
                  hintStyle: TextStyle(color: Colors.black),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    consoleController.executeCommand(value);
                    textEditingController.clear();
                    textFieldFocusNode.requestFocus();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}