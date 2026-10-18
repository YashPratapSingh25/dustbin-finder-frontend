// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dustbin_finder/framework/controller/dustbin_controller.dart'
    as _i121;
import 'package:dustbin_finder/framework/core/network/api_client.dart' as _i424;
import 'package:dustbin_finder/framework/repository/dustbin/contract/dustbin_repository.dart'
    as _i241;
import 'package:dustbin_finder/framework/repository/dustbin/repository/dustbin_api_repository.dart'
    as _i846;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i424.ApiClient>(() => _i424.ApiClient());
    gh.lazySingleton<_i241.DustbinRepository>(
        () => _i846.DustbinApiRepository(gh<_i424.ApiClient>()));
    gh.factory<_i121.DustbinController>(
        () => _i121.DustbinController(gh<_i241.DustbinRepository>()));
    return this;
  }
}
