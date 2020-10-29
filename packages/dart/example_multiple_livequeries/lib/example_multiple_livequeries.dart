import 'dart:math';
import 'package:parse_server_sdk/parse_server_sdk.dart';

Future<void> init() async {
  await Parse().initialize(
    'Parse-Demo',
    'https://parse-demo.thomax-it.com/parseserver',
    clientKey: 'jyHsBFje6ShMWe6TW3FXQtuWW87HWPLx2YHFCWKS9ua8FY8nbT',
    liveQueryUrl: 'https://parse-demo.thomax-it.com/parseserver',
    connectivityProvider: ConnectivityProvider(),
  );
}

Future<void> listen() async {
  final QueryBuilder<ParseObject> query1 =
      QueryBuilder<ParseObject>.name("table1");
  final QueryBuilder<ParseObject> query2 =
      QueryBuilder<ParseObject>.name("table2");

  (await LiveQuery().client.subscribe(query1))
    ..on(LiveQueryEvent.create,
        (ParseObject object) => print('CREATE in table1: $object'))
    ..on(LiveQueryEvent.delete,
        (ParseObject object) => print('DELETE in table1: $object'));

  (await LiveQuery().client.subscribe(query2))
    ..on(LiveQueryEvent.create,
        (ParseObject object) => print('CREATE in table2: $object'))
    ..on(LiveQueryEvent.delete,
        (ParseObject object) => print('DELETE in table2: $object'));

  print('listening');
}

Future<void> createNoise() async {
  (ParseObject('table1')..set('text', getRandomString(5)))
      .save()
      .then((ParseResponse parseResponse) {
    if (parseResponse.success) {
      Future<void>.delayed(Duration(milliseconds: _rnd.nextInt(2000)))
          .then<ParseResponse>((_) => parseResponse.results?.first?.delete());
    }
  });
  (ParseObject('table2')..set('text', getRandomString(5)))
      .save()
      .then((ParseResponse parseResponse) {
    if (parseResponse.success) {
      Future<void>.delayed(Duration(milliseconds: _rnd.nextInt(2000)))
          .then<ParseResponse>((_) => parseResponse.results?.first?.delete());
    }
  });
}

const String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class ConnectivityProvider extends ParseConnectivityProvider{
  @override
  Future<ParseConnectivityResult> checkConnectivity() async {
    return ParseConnectivityResult.wifi;
  }

  @override
  Stream<ParseConnectivityResult> get connectivityStream async*{
    yield ParseConnectivityResult.wifi;
  }
}