import 'package:flutter/foundation.dart';
import 'dart:async';

enum LogLevel { debug, info, warning, error, critical }

class LogEntry {
  final DateTime timestamp;
  final String message;
  final LogLevel level;
  final String? source;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    this.source,
    this.stackTrace,
  });

  String get formattedTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';

  String get levelName => level.name.toUpperCase();

  String get colorCode {
    switch (level) {
      case LogLevel.debug:
        return '\x1B[36m'; // Cyan
      case LogLevel.info:
        return '\x1B[32m'; // Green
      case LogLevel.warning:
        return '\x1B[33m'; // Yellow
      case LogLevel.error:
        return '\x1B[31m'; // Red
      case LogLevel.critical:
        return '\x1B[35m'; // Magenta
    }
  }

  String get formatted =>
      '$colorCode[$formattedTime] [$levelName]${source != null ? ' [$source]' : ''}: $message\x1B[0m';

  @override
  String toString() => formatted;
}

/// Service centralisé de logging
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal();

  final List<LogEntry> _logs = [];
  final StreamController<LogEntry> _logController =
      StreamController<LogEntry>.broadcast();

  Stream<LogEntry> get logStream => _logController.stream;
  List<LogEntry> get allLogs => List.unmodifiable(_logs);

  int get maxLogs => 500; // Limiter la taille du buffer

  void debug(String message, {String? source, StackTrace? stackTrace}) {
    _addLog(
      LogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: LogLevel.debug,
        source: source,
        stackTrace: stackTrace,
      ),
    );
  }

  void info(String message, {String? source, StackTrace? stackTrace}) {
    _addLog(
      LogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: LogLevel.info,
        source: source,
        stackTrace: stackTrace,
      ),
    );
  }

  void warning(String message, {String? source, StackTrace? stackTrace}) {
    _addLog(
      LogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: LogLevel.warning,
        source: source,
        stackTrace: stackTrace,
      ),
    );
  }

  void error(String message, {String? source, StackTrace? stackTrace}) {
    _addLog(
      LogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: LogLevel.error,
        source: source,
        stackTrace: stackTrace,
      ),
    );
  }

  void critical(String message, {String? source, StackTrace? stackTrace}) {
    _addLog(
      LogEntry(
        timestamp: DateTime.now(),
        message: message,
        level: LogLevel.critical,
        source: source,
        stackTrace: stackTrace,
      ),
    );
  }

  void _addLog(LogEntry entry) {
    _logs.add(entry);
    _logController.add(entry);

    // Afficher dans la console en debug
    if (kDebugMode) {
      print(entry.formatted);
    }

    // Limiter la taille du buffer
    if (_logs.length > maxLogs) {
      _logs.removeRange(0, _logs.length - maxLogs);
    }
  }

  /// Exporter les logs en format texte
  String exportLogs({LogLevel? minLevel}) {
    final filtered = _logs
        .where((log) => minLevel == null || log.level.index >= minLevel.index)
        .toList();
    return filtered.map((e) => e.formatted).join('\n');
  }

  /// Effacer tous les logs
  void clear() {
    _logs.clear();
  }

  /// Filtrer les logs par niveau
  List<LogEntry> getLogsAtLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Filtrer les logs par source
  List<LogEntry> getLogsBySource(String source) {
    return _logs.where((log) => log.source?.contains(source) ?? false).toList();
  }

  void dispose() {
    _logController.close();
  }
}

// Singleton global
final log = LoggingService();
