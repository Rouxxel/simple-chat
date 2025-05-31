import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileLogOutput extends LogOutput {
  final File logFile;
  IOSink? _sink;

  FileLogOutput(this.logFile) {
    _sink = logFile.openWrite(mode: FileMode.append);
  }

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      _sink?.writeln(line);
    }
  }

  @override
  Future<void> destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}

class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiOutput(this.outputs);

  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }

  @override
  Future<void> destroy() async {
    for (var output in outputs) {
      await output.destroy();
    }
  }
}

Logger? log_handler;

Future<void> init_logger() async {
  final directory = await getApplicationDocumentsDirectory();

  final now = DateTime.now();
  final timestamp = now.toIso8601String().replaceAll(':', '-');
  final logFile = File('${directory.path}/log_$timestamp.log');

  log_handler = Logger(
    output: MultiOutput([
      ConsoleOutput(),
      FileLogOutput(logFile),
    ]),
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}
