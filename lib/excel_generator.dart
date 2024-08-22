

import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelGenerator {

  Future<void> convertArbToExcel() async {
    // ARB 파일 선택
    FilePickerResult? arbResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['arb'],
      allowMultiple: true,
    );

    if (arbResult != null) {
      List<File> arbFiles = arbResult.paths.map((path) => File(path!)).toList();

      // 엑셀 파일을 저장할 디렉터리 선택
      String? outputDirectory = await FilePicker.platform.getDirectoryPath();

      if (outputDirectory != null) {

        // ARB 파일을 엑셀로 변환
        await _arbToExcel(arbFiles, outputDirectory);

      } else {
        throw Exception('No directory selected');
      }
    } else {
      throw Exception('No ARB files selected');
    }
  }

  Future<void> _arbToExcel(List<File> arbFiles, String outputDirectory) async {
    var excel = Excel.createExcel(); // 새 엑셀 파일 생성
    List<String> fileName = [];



    for(var arbFile in arbFiles) {
      List<String> pathSegments = arbFile.path.split('/');
      String lastSegment = pathSegments.last;

      // 마지막 경로 부분에서 language code 추출
      RegExp regExp = RegExp(r'_(\w+)\.');
      Match? match = regExp.firstMatch(lastSegment);
      fileName.add(match!.group(1)!);
    }


    var content = await arbFiles[0].readAsString();
    var jsonData = json.decode(content) as Map<String, dynamic>;

    // ARB 파일에서 page 속성에 따라 데이터를 시트로 나눔
    Map<String, List<List<dynamic>>> sheetsData = {};

    for (var entry in jsonData.entries) {

      if (entry.key.startsWith('@')) {
        var description = entry.value['description'] ?? '';
        var page = entry.value['page'] ?? 'Default';

        if (!sheetsData.containsKey(page)) {
          sheetsData[page] = [['Key', 'Description'] + fileName];
        }

        // @key 부분은 엑셀 행에 추가하지 않음
      } else {

        // 데이터가 'Key'일 때
        var page = jsonData['@${entry.key}']?['page'] ?? 'Default';
        if (!sheetsData.containsKey(page)) {
          sheetsData[page] = [['Key', 'Description'] + fileName];
        }


        var description = jsonData['@${entry.key}']?['description'] ?? '';
        List<String> row = [entry.key, description];

        for(int i = 0; i < arbFiles.length ; i++) {

          var content = await arbFiles[i].readAsString();
          var jsonData = json.decode(content) as Map<String, dynamic>;

          row.add(jsonData[entry.key]);
        }

        sheetsData[page]!.add(row);

      }
    }

    // 시트 추가 및 데이터 삽입
    sheetsData.forEach((sheetName, data) {
      var sheet = excel[sheetName];
      data.forEach((row) => sheet.appendRow(row));
    });

    // 엑셀 파일 저장
    String excelFilePath = '$outputDirectory/translated_strings.xlsx';
    var excelFile = File(excelFilePath);
    await excelFile.writeAsBytes(excel.encode()!);
  }
}

