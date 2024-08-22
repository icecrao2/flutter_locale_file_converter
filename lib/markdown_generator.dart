

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';


class MarkdownGenerator {

  Future<void> convertExcelToMarkdown() async {
    // 엑셀 파일 선택
    FilePickerResult? excelResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (excelResult != null) {
      File excelFile = File(excelResult.files.single.path!);

      String? outputDirectory = await FilePicker.platform.getDirectoryPath();

      if (outputDirectory != null) {

        await _convertExcelToMarkdown(excelFile, outputDirectory);
      } else {
        throw Exception('No directory selected');
      }
    } else {
      throw Exception('No Excel file selected');
    }
  }

  Future<void> _convertExcelToMarkdown(File file, String outputDirectory) async {
    // 엑셀 파일 로드
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      throw Exception('No sheets found in the Excel file');
    }

    // README 파일 생성
    StringBuffer readmeBuffer = StringBuffer();

    // 각 시트의 데이터 처리
    for (var tableName in excel.tables.keys) {
      var sheet = excel.tables[tableName]!;

      if (sheet.maxCols < 3) {
        continue;
      }

      // 시트 제목 추가
      readmeBuffer.writeln('## $tableName\n');

      // 테이블 헤더 추가
      var headers = sheet.rows[0].map((cell) => cell?.value.toString()).toList();
      readmeBuffer.writeln('| ${headers.join(' | ')} |');
      readmeBuffer.writeln('| ${List.filled(headers.length, '---').join(' | ')} |');

      // 테이블 데이터 추가
      for (var row in sheet.rows.skip(1)) {
        var rowData = row.map((cell) => cell?.value.toString() ?? '').toList();
        readmeBuffer.writeln('| ${rowData.join(' | ')} |');
      }

      // 시트 간 구분
      readmeBuffer.writeln('\n');
    }

    // .README 파일로 저장
    String readmeFilePath = '$outputDirectory/translation.md';
    File readmeFile = File(readmeFilePath);
    await readmeFile.writeAsString(readmeBuffer.toString());
  }
}





