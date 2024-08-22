

import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';



class ArbGenerator {

  void convertExcelToArb() async {
    await _pickAndProcessFile();
  }


  Future<void> _pickAndProcessFile() async {
    // 엑셀 파일 선택
    FilePickerResult? excelResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (excelResult != null) {
      File excelFile = File(excelResult.files.single.path!);

      // ARB 파일을 저장할 디렉터리 선택
      String? outputDirectory = await FilePicker.platform.getDirectoryPath();

      if (outputDirectory != null) {
        await _processExcelFile(excelFile, outputDirectory);
      } else {
        throw Exception('No directory selected');
      }
    } else {
      throw Exception('No file selected');
    }
  }

  Future<void> _processExcelFile(File file, String outputDirectory) async {
    // 엑셀 파일 로드
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      throw Exception('No sheets found in the Excel file');
    }

    // 언어별 ARB 데이터 구조 생성
    Map<String, Map<String, dynamic>> arbFilesContent = {};

    // 모든 시트 처리
    for (var tableName in excel.tables.keys) {
      var sheet = excel.tables[tableName]!;

      if (sheet.maxCols < 3) {
        continue;
      }

      // 첫 번째 행은 언어 제목 (나라 이름)
      var languageTitles = sheet.rows[0].skip(2).map((cell) => cell?.value.toString()).toList();

      // 나머지 행은 키, 설명, 다국어 문자열
      for (var row in sheet.rows.skip(1)) {
        var key = row[0]?.value.toString();
        var description = row[1]?.value.toString();

        if (key != null) {
          for (int i = 2; i < row.length; i++) {
            var languageKey = languageTitles[i - 2];
            var value = row[i]?.value.toString() ?? '';

            if (languageKey != null) {
              // 해당 언어의 ARB 파일 데이터에 추가
              arbFilesContent.putIfAbsent(languageKey, () => {});
              arbFilesContent[languageKey]![key] = value;
              arbFilesContent[languageKey]!['@$key'] = {
                "description": description,
                "page": tableName,
              };
            }
          }
        }
      }
    }

    // ARB 파일 생성 (각 나라별로)
    var encoder = JsonEncoder.withIndent('  '); // 2칸 들여쓰기
    for (var entry in arbFilesContent.entries) {
      String arbJson = encoder.convert(entry.value);
      String arbFilePath = '$outputDirectory/app_${entry.key}.arb';
      File arbFile = File(arbFilePath);
      await arbFile.writeAsString(arbJson);
    }
  }
}