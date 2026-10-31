enum AppEnvironmentName { development, staging, production }

final class AppEnvironment {
  const AppEnvironment._({
    required this.name,
    required this.apiBaseUrl,
  });

  factory AppEnvironment.fromBuildDefines() {
    const environmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    const apiBaseUrlValue = String.fromEnvironment('API_BASE_URL');

    return AppEnvironment.fromValues(
      name: environmentName,
      apiBaseUrl: apiBaseUrlValue.isEmpty ? null : apiBaseUrlValue,
    );
  }

  factory AppEnvironment.fromValues({
    required String name,
    String? apiBaseUrl,
  }) {
    final parsedName = switch (name) {
      'development' => AppEnvironmentName.development,
      'staging' => AppEnvironmentName.staging,
      'production' => AppEnvironmentName.production,
      _ => throw FormatException('Unsupported APP_ENV value: $name'),
    };

    final parsedApiBaseUrl = _parseApiBaseUrl(apiBaseUrl);

    return AppEnvironment._(
      name: parsedName,
      apiBaseUrl: parsedApiBaseUrl,
    );
  }

  final AppEnvironmentName name;
  final Uri? apiBaseUrl;

  static Uri? _parseApiBaseUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.isAbsolute ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw FormatException('API_BASE_URL must be an absolute HTTP(S) URL.');
    }

    return uri;
  }
}
