import 'package:json_to_floor_entity/json_to_floor_entity.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  const defaultSource = './jsons/';
  const defaultOutput = './lib/models/';
  const defaultDaoDir = './lib/dao/';
  const defaultCipher = 'false';

  String? source = '';
  String? output = '';
  String? onlyFile;
  String? daoDir = '';
  String? cipher = 'false';

  var argParser = ArgParser();
  argParser.addOption(
    'source',
    abbr: 's',
    defaultsTo: defaultSource,
    callback: (v) => source = v,
    help: 'Specify source directory',
  );
  argParser.addOption(
    'output',
    abbr: 'o',
    defaultsTo: defaultOutput,
    callback: (v) => output = v,
    help: 'Specify models directory',
  );
  argParser.addOption(
    'onlyFile',
    abbr: 'f',
    callback: (v) => onlyFile = v,
    help: 'Specify file to read',
  );
  argParser.addOption(
    'daoDir',
    abbr: 'd',
    callback: (v) => daoDir = v,
    help: 'Specify dao Dir to read',
  );
  argParser.addOption(
    'cipher',
    abbr: 'c',
    callback: (v) => cipher = v,
    help: 'Specify if need cipher',
  );
  argParser.parse(arguments);
  var runner = JsonModelRunner(
    source: source ?? defaultSource,
    output: output ?? defaultOutput,
    onlyFile: onlyFile,
    daoDir: daoDir ?? defaultDaoDir,
    cipher: cipher ?? defaultCipher,
  );

  runner.setup();

  print('Start generating');
  if (runner.run()) {
    // cleanup on success
    print('Cleanup');
    runner.cleanup();
  }
}
