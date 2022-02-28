import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main(){

  //Aşağıdaki kodu yazmazsam asenkron olarak yazdığım bildirim metodu hata veriyor
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidNotificationDetails = AndroidNotificationDetails(
    'MYID',
    'NOTIFICATION',
    channelDescription: 'Description',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  Future<void> showNotificationMessage(String message1, String message2 , int seconds) async {
    const AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');

    const IOSInitializationSettings initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null,
    );

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,);

/*    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );*/

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: _androidNotificationDetails);

    //Hemen bildirim göndermek için alttaki kodlar yazılabilir
/*    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(9000),
//NOTIFICATION ID - SHOULD BE UNIQUE/RANDOM
      message1,
      message2,
      platformChannelSpecifics,
    );*/

    //Aşağıdaki kodlarla kullanıcının belirlediği süre sonra bildirim gönderiliyor
    var tzDateTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      seconds,
      message1,
      message2,
      tzDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
}

  @override
  Widget build(BuildContext context) {
    var setAlarmTime=TextEditingController();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  Scaffold(
        appBar: AppBar(title: const Text("Send Timely Notification")),
        body: Center(
          child:
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50.0),
            child: TextField(
              controller: setAlarmTime,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.alarm_add),
                labelText: "Bildirim zamanını düzenleyin",
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 3, color: Colors.blue),
                  borderRadius: BorderRadius.circular(15),
                ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 3, color: Colors.red),
                    borderRadius: BorderRadius.circular(15),
                  )
            ),

              onSubmitted: (m) async {
                //String olarak belirlenen TextEditingController daki yazı int e çevriliyor ve null kontrolü yapılıyor. Eğer null ise bildirim hemen yapılıyor yoksa
                //belirlenen süre sonunda bildirim yapılıyor.
                var seconds=int.parse(m);

                showNotificationMessage('Günaydın!','Günlük görevleri kontrol etmeyi unutmayın!',seconds);

              }
          ),
          ),
          )
        ),
    );
  }
}



