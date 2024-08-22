
import 'package:flutter/material.dart';

import 'arb_generator.dart';
import 'excel_generator.dart';
import 'markdown_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel to ARB Generator',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Excel to ARB Generator'),
        ),
        body: const Center(
          child: ExcelToArbWidget(),
        ),
      ),
    );
  }
}

class ExcelToArbWidget extends StatefulWidget {

  const ExcelToArbWidget({super.key});

  @override
  State createState() => _ExcelToArbWidgetState();
}

class _ExcelToArbWidgetState extends State<ExcelToArbWidget> {

  final ArbGenerator _arbGenerator = ArbGenerator();
  final ExcelGenerator _excelGenerator = ExcelGenerator();
  final MarkdownGenerator _markdownGenerator = MarkdownGenerator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _arbGenerator.convertExcelToArb,
          child: const Text('convert excel to arb'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _excelGenerator.convertArbToExcel,
          child: const Text('convert arb to excel'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _markdownGenerator.convertExcelToMarkdown,
          child: const Text('convert excel markdown'),
        ),
      ],
    );
  }
}