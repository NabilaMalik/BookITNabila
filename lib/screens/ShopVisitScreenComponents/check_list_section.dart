import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChecklistSection extends StatelessWidget {
  final List<String> labels;
  final RxList<bool> checklistState;
  final Function(int index, bool value) onStateChanged;

  const ChecklistSection({
    Key? key,
    required this.labels,
    required this.checklistState,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Checklist", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Obx(() {
          return Column(
            children: List.generate(labels.length, (index) {
              return CheckboxListTile(
                title: Text(labels[index]),
                value: checklistState[index],
                onChanged: (value) {
                  onStateChanged(index, value!);
                },
              );
            }),
          );
        }),
      ],
    );
  }
}
