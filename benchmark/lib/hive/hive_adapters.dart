import 'package:hive_ce/hive.dart';
import 'package:sleek_storage_benchmark/models/test_model_advanced.dart';
import 'package:sleek_storage_benchmark/models/test_model_basic.dart';

@GenerateAdapters([
  AdapterSpec<TestModelBasic>(),
  AdapterSpec<TestModelAdvancedHiveAdapter>(),
])
part 'hive_adapters.g.dart';
