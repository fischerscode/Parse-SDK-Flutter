part of flutter_parse_sdk;

/// Singleton class that defines all user keys and data
class ParseCoreData {
  factory ParseCoreData() => _instance;

  ParseCoreData._init(this.applicationId, this.serverUrl);

  static ParseCoreData _instance;

  static ParseCoreData get instance => _instance;

  /// Creates an instance of Parse Server
  ///
  /// This class should not be user unless switching servers during the app,
  /// which is odd. Should only be user by Parse.init
  static Future<void> init(String appId, String serverUrl,
      {bool debug,
      String appName,
      String liveQueryUrl,
      String masterKey,
      String clientKey,
      String sessionId,
      bool autoSendSessionId,
      SecurityContext securityContext,
      CoreStore store,
      Map<String, ParseObjectConstructor> registeredSubClassMap,
      ParseUserConstructor parseUserConstructor}) async {
    _instance = ParseCoreData._init(appId, serverUrl);

    _instance.storage ??=
        store ?? await CoreStoreSharedPrefsImp.getInstance(password: masterKey);

    if (debug != null) {
      _instance.debug = debug;
    }
    if (appName != null) {
      _instance.appName = appName;
    }
    if (liveQueryUrl != null) {
      _instance.liveQueryURL = liveQueryUrl;
    }
    if (clientKey != null) {
      _instance.clientKey = clientKey;
    }
    if (masterKey != null) {
      _instance.masterKey = masterKey;
    }
    if (sessionId != null) {
      _instance.sessionId = sessionId;
    }
    if (autoSendSessionId != null) {
      _instance.autoSendSessionId = autoSendSessionId;
    }
    if (securityContext != null) {
      _instance.securityContext = securityContext;
    }

    _instance._subClassHandler = ParseSubClassHandler(
      registeredSubClassMap: registeredSubClassMap,
      parseUserConstructor: parseUserConstructor,
    );
  }

  String appName;
  String applicationId;
  String serverUrl;
  String liveQueryURL;
  String masterKey;
  String clientKey;
  String sessionId;
  bool autoSendSessionId;
  SecurityContext securityContext;
  bool debug;
  CoreStore storage;
  ParseSubClassHandler _subClassHandler;

  void registerSubClass(
      String className, ParseObjectConstructor objectConstructor) {
    _subClassHandler.registerSubClass(className, objectConstructor);
  }

  void registerUserSubClass(ParseUserConstructor parseUserConstructor) {
    _subClassHandler.registerUserSubClass(parseUserConstructor);
  }

  ParseObject createObject(String classname) {
    return _subClassHandler.createObject(classname);
  }

  ParseUser createParseUser(
      String username, String password, String emailAddress,
      {String sessionToken, bool debug, ParseHTTPClient client}) {
    return _subClassHandler.createParseUser(username, password, emailAddress,
        sessionToken: sessionToken, debug: debug, client: client);
  }

  /// Sets the current sessionId.
  ///
  /// This is generated when a users logs in, or calls currentUser to update
  /// their keys
  void setSessionId(String sessionId) {
    this.sessionId = sessionId;
  }

  CoreStore getStore() {
    return storage;
  }

  @override
  String toString() => '$applicationId $masterKey';
}
