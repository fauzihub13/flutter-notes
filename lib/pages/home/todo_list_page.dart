import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_taptime/models/push_notif.dart';
import 'package:overlay_support/overlay_support.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late final FirebaseMessaging _firebaseMessaging;
  int _totalNotification = 0;
  String test = "Hai";
  PushNotif? _notifInfo;

  void regisNotification() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    Future<void> _firebaseMessageHandler(RemoteMessage remoteMessage) async {
      print('Handling message: ${remoteMessage.messageId}');
    }

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessageHandler);

    NotificationSettings notificationSettings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('Notifikasi diizinkan');
      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
        // print(remoteMessage);
        print(remoteMessage.notification?.title);
        print(remoteMessage.notification?.body);
        PushNotif pushNotif = PushNotif(
          title: remoteMessage.notification?.title,
          body: remoteMessage.notification?.body,
          dataTitle: remoteMessage.data['title'],
          dataBody: remoteMessage.data['body'],
        );

        print('Assigned to push notif model');
        print('Before update: $test');
        setState(() {
          test = " Ganti";
          _notifInfo = pushNotif;
          _totalNotification++;
        });
        print('After update: $test');
        print(_notifInfo?.dataBody);

        print('Notification count updated: $_totalNotification');

        if (_notifInfo != null) {
          print('notif ada isinya untuk di pop up overlay');
          showSimpleNotification(Text(_notifInfo!.title!),
              leading: const Icon(Icons.notifications),
              subtitle: Text(_notifInfo!.body!),
              duration: const Duration(seconds: 3));
        } else {
          print('Notif info kosong');
        }
      });
    } else {
      print("Notifikasi tidak diizinkan");
    }
  }

  checkMessage() async {
    RemoteMessage? _initialMessage;
    await FirebaseMessaging.instance.getInitialMessage();
    if (_initialMessage != null) {
      PushNotif initialPushNotif = PushNotif(
          title: _initialMessage.notification?.title,
          body: _initialMessage.notification?.body);
      setState(() {
        _notifInfo = initialPushNotif;
        _totalNotification++;
      });
    }
  }

  @override
  void initState() {
    // _totalNotification = 0;
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      PushNotif notification = PushNotif(
          title: remoteMessage.notification?.title,
          body: remoteMessage.notification?.body);
    });
    regisNotification();
    checkMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('To Do List'),
          backgroundColor: Colors.lightBlue,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            children: [
              Text("Total Notifikasi: ${_totalNotification.toString()}"),
              const SizedBox(
                height: 40,
              ),
              if (_notifInfo != null)
                Column(
                  children: [
                    Text('${_notifInfo!.dataTitle ?? _notifInfo!.title}'),
                    Text('${_notifInfo!.dataBody ?? _notifInfo!.body}'),
                  ],
                )
              else
                Text('notif info null'),
            ],
          ),
        ));
  }
}
