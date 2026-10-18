enum AppEnvironment { dev, qa, prod }

class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static AppEnvironment get environment => AppEnvironment.values.firstWhere(
        (value) => value.name == _environmentName,
        orElse: () => AppEnvironment.dev,
      );

  static String get name => environment.name.toUpperCase();

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    switch (environment) {
      case AppEnvironment.dev:
        return 'http://192.168.1.10:8000';
      case AppEnvironment.qa:
        return 'https://qa-api.example.com';
      case AppEnvironment.prod:
        return 'https://api.example.com';
    }
  }
}
