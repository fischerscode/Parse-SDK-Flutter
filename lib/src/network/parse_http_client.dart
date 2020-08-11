part of flutter_parse_sdk;

/// Creates a custom version of HTTP Client that has Parse Data Preset
class ParseHTTPClient with DioMixin implements Dio {
  ParseHTTPClient({
    this.sendSessionId = false,
    SecurityContext securityContext,
  }) {
    options = BaseOptions();
    httpClientAdapter = createHttpClientAdapter(securityContext);
  }

  final bool sendSessionId;
  Map<String, String> additionalHeaders;

  final String _userAgent = '$keyLibraryName $keySdkVersion';
  ParseCoreData data = ParseCoreData();

  @override
  Future<Response<T>> request<T>(
    String path, {
    dynamic data,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    Options options,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) {
    options ??= Options();
    if (!identical(0, 0.0)) {
      options.headers[keyHeaderUserAgent] = _userAgent;
    }
    options.headers[keyHeaderApplicationId] = this.data.applicationId;
    if ((sendSessionId == true) &&
        (this.data.sessionId != null) &&
        (options.headers[keyHeaderSessionToken] == null))
      options.headers[keyHeaderSessionToken] = this.data.sessionId;

    if (this.data.clientKey != null)
      options.headers[keyHeaderClientKey] = this.data.clientKey;
    if (this.data.masterKey != null)
      options.headers[keyHeaderMasterKey] = this.data.masterKey;

    /// If developer wants to add custom headers, extend this class and add headers needed.
    if (additionalHeaders != null && additionalHeaders.isNotEmpty) {
      additionalHeaders
          .forEach((String key, String value) => options.headers[key] = value);
    }

    if (this.data.debug) {
      logCUrl(options, data, path);
    }

    return super.request(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
