part of flutter_parse_sdk;

class ParseWebFile extends ParseFileBase {
  ParseWebFile(
    this.file, {
    @required String name,
    String url,
    bool debug,
    ParseHTTPClient client,
    bool autoSendSessionId,
    ParseHTTPDioClient dioClient,
  }) : super(
          name: name,
          url: url,
          debug: debug,
          client: client,
          autoSendSessionId: autoSendSessionId,
          dioClient: dioClient,
        );

  Uint8List file;

  @override
  Future<ParseWebFile> download() async {
    if (url == null) {
      return this;
    }

    final Response response = await _client.get(url);
    file = response.bodyBytes;

    return this;
  }

  @override
  Future<ParseResponse> upload({dio.ProgressCallback progressCallback}) async {
    if (saved) {
      //Creates a Fake Response to return the correct result
      final Map<String, String> response = <String, String>{
        'url': url,
        'name': name
      };
      return handleResponse<ParseWebFile>(
          this,
          Response(json.encode(response), 201),
          ParseApiRQ.upload,
          _debug,
          parseClassName);
    } else {
      final Map<String, String> headers = <String, String>{
        HttpHeaders.contentTypeHeader: url ?? name != null
            ? getContentType(path.extension(url ?? name))
            : 'text/plain'
      };
      try {
        final String uri = _client.data.serverUrl + '$_path';
        if (progressCallback == null) {
          final Response response =
              await _client.post(uri, headers: headers, body: file);
          if (response.statusCode == 201) {
            final Map<String, dynamic> map = json.decode(response.body);
            url = map['url'].toString();
            name = map['name'].toString();
          }
          return handleResponse<ParseWebFile>(
              this, response, ParseApiRQ.upload, _debug, parseClassName);
        } else {
          // use dio
          final dio.Response<String> response = await _dioClient.post<String>(
            uri,
            options: dio.Options(headers: headers),
            data: file,
            onSendProgress: progressCallback,
          );
          if (response.statusCode == 201) {
            final Map<String, dynamic> map = json.decode(response.data);
            url = map['url'].toString();
            name = map['name'].toString();
          }
          return handleResponse<ParseFile>(
              this,
              // copy dio.Response to Response (only body and statusCode is needed later)
              Response(
                response.data,
                response.statusCode,
              ),
              ParseApiRQ.upload,
              _debug,
              parseClassName);
        }
      } on Exception catch (e) {
        return handleException(e, ParseApiRQ.upload, _debug, parseClassName);
      }
    }
  }
}
