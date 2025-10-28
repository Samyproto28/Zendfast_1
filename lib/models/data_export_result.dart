import 'dart:io';

/// Result of a data export operation
/// Contains file path, metadata, and statistics about the export
class DataExportResult {
  /// Path to the exported ZIP file
  final File file;

  /// Size of the exported file in bytes
  final int fileSizeBytes;

  /// When the export was created
  final DateTime exportedAt;

  /// Count of records exported by table/entity type
  final Map<String, int> recordCounts;

  /// Format of the export
  final ExportFormat format;

  /// Total number of records across all tables
  final int totalRecords;

  /// Constructor
  DataExportResult({
    required this.file,
    required this.fileSizeBytes,
    required this.exportedAt,
    required this.recordCounts,
    this.format = ExportFormat.zip,
  }) : totalRecords = recordCounts.values.fold(0, (sum, count) => sum + count);

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// Get file name
  String get fileName => file.path.split('/').last;

  /// Get formatted export date
  String get formattedExportDate {
    return '${exportedAt.day.toString().padLeft(2, '0')}/'
        '${exportedAt.month.toString().padLeft(2, '0')}/'
        '${exportedAt.year} ${exportedAt.hour.toString().padLeft(2, '0')}:'
        '${exportedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Convert to JSON for audit logging
  Map<String, dynamic> toJson() {
    return {
      'file_path': file.path,
      'file_size_bytes': fileSizeBytes,
      'exported_at': exportedAt.toIso8601String(),
      'record_counts': recordCounts,
      'format': format.toString().split('.').last,
      'total_records': totalRecords,
    };
  }

  /// Get summary string
  String get summary {
    return 'Exported $totalRecords records ($formattedFileSize) on $formattedExportDate';
  }

  /// Get detailed breakdown string
  String get detailedBreakdown {
    final buffer = StringBuffer();
    buffer.writeln('Export Details:');
    buffer.writeln('- Total Records: $totalRecords');
    buffer.writeln('- File Size: $formattedFileSize');
    buffer.writeln('- Export Date: $formattedExportDate');
    buffer.writeln('- Format: ${format.toString().split('.').last.toUpperCase()}');
    buffer.writeln('\nRecords by Type:');
    recordCounts.forEach((table, count) {
      buffer.writeln('  - $table: $count records');
    });
    return buffer.toString();
  }
}

/// Export format type
enum ExportFormat {
  zip,  // ZIP archive containing JSON and CSV files
  json, // JSON only
  csv,  // CSV only
}
