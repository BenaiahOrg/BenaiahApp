// @dart=3.6
// ignore_for_file: type=lint
// build_runner >=2.4.16
import 'dart:io' as _io;
import 'package:build_runner/src/build_plan/builder_factories.dart'
    as _build_runner;
import 'package:build_runner/src/bootstrap/processes.dart' as _build_runner;
import 'package:flutter_gen_runner/flutter_gen_runner.dart' as _i1;
import 'package:freezed/builder.dart' as _i2;
import 'package:injectable_generator/builder.dart' as _i3;
import 'package:json_serializable/builder.dart' as _i4;
import 'package:mockito/src/builder.dart' as _i5;
import 'package:riverpod_generator/builder.dart' as _i6;
import 'package:source_gen/builder.dart' as _i7;

final _builderFactories = _build_runner.BuilderFactories(
  {
    'flutter_gen_runner:flutter_gen_runner': [_i1.build],
    'freezed:freezed': [_i2.freezed],
    'injectable_generator:injectable_builder': [_i3.injectableBuilder],
    'injectable_generator:injectable_config_builder': [
      _i3.injectableConfigBuilder
    ],
    'json_serializable:json_serializable': [_i4.jsonSerializable],
    'mockito:mockBuilder': [_i5.buildMocks],
    'riverpod_generator:riverpod_generator': [_i6.riverpodBuilder],
    'source_gen:combining_builder': [_i7.combiningBuilder],
  },
  postProcessBuilderFactories: {
    'flutter_gen_runner:flutter_gen_runner_post_process': _i1.postProcessBuild,
    'source_gen:part_cleanup': _i7.partCleanup,
  },
);
void main(List<String> args) async {
  _io.exitCode = await _build_runner.ChildProcess.run(
    args,
    _builderFactories,
  )!;
}
