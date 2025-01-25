import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_taptime/models/note_model.dart';
import 'package:flutter_taptime/models/push_notif.dart';
import 'package:flutter_taptime/models/user_model.dart';
import 'package:flutter_taptime/services/auth_service.dart';
import 'package:flutter_taptime/services/db_helper.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sqflite/sqflite.dart';

class TodoListPage extends StatefulWidget {
  final UserModel? userModel;
  const TodoListPage({super.key, this.userModel});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late final FirebaseMessaging _firebaseMessaging;
  final AuthService authService = AuthService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DbHelper dbHelper = DbHelper();
  List<NoteModel> noteList = [];
  int count = 0;

  int _totalNotification = 0;
  String test = "Hai";
  PushNotif? _notifInfo;

  void regisNotification() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    // Future<void> _firebaseMessageHandler(RemoteMessage remoteMessage) async {
    //   print('Handling message: ${remoteMessage.messageId}');
    // }

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessageHandler);

    NotificationSettings notificationSettings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      // print('Notifikasi diizinkan');
      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
        // print(remoteMessage);
        // print(remoteMessage.notification?.title);
        // print(remoteMessage.notification?.body);
        PushNotif pushNotif = PushNotif(
          title: remoteMessage.notification?.title,
          body: remoteMessage.notification?.body,
          dataTitle: remoteMessage.data['title'],
          dataBody: remoteMessage.data['body'],
        );

        // print('Assigned to push notif model');
        // print('Before update: $test');
        setState(() {
          test = " Ganti";
          _notifInfo = pushNotif;
          _totalNotification++;
        });
        // print('After update: $test');
        // print(_notifInfo?.dataBody);

        // print('Notification count updated: $_totalNotification');

        if (_notifInfo != null) {
          // print('notif ada isinya untuk di pop up overlay');
          showSimpleNotification(Text(_notifInfo!.title!),
              leading: const Icon(Icons.notifications),
              subtitle: Text(_notifInfo!.body!),
              duration: const Duration(seconds: 5),
              background: Colors.green);
        } else {
          // print('Notif info kosong');
        }
      });
    } else {
      // print("Notifikasi tidak diizinkan");
    }
  }

  checkMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotif initialPushNotif = PushNotif(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      setState(() {
        _notifInfo = initialPushNotif;
        _totalNotification++;
      });
    }
  }

  // Modal Bottom Sheet
  Future<void> _createOrUpdate({NoteModel? noteModel}) async {
    String action = 'create';
    _titleController.text = '';
    _descriptionController.text = '';
    if (noteModel != null) {
      action = 'update';
      _titleController.text = noteModel.title!;
      _descriptionController.text = noteModel.description!;
    }

    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Judul"),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (action == 'create') {
                        if (_titleController.text.isEmpty ||
                            _descriptionController.text.isEmpty) return;
                        NoteModel noteModel = NoteModel(
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            userId: widget.userModel!.uid);
                        _createNote(noteModel);
                        Navigator.pop(context);
                      } else if (action == 'update') {
                        noteModel!.title = _titleController.text.trim();
                        noteModel.description =
                            _descriptionController.text.trim();
                        _updateNote(noteModel);
                        Navigator.pop(context);
                      } else {}
                    },
                    child: const Text('Simpan'))
              ],
            ),
          );
        });
  }

  // Build Listview
  ListView createNoteListView() {
    _updateListView();
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3.0,
            color: Colors.white,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.notes),
              ),
              title: Text(noteList[index].title!),
              subtitle: Text(noteList[index].description!),
              trailing: GestureDetector(
                child: const Icon(Icons.delete),
                onTap: () {
                  _deleteNote(noteList[index]);
                },
              ),
              onTap: () async {
                _createOrUpdate(noteModel: noteList[index]);
              },
            ),
          );
        });
  }

  // Fetch Data From SQFLite
  void _updateListView() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<NoteModel>> noteListFuture = dbHelper.getAllData();
      noteListFuture.then((noteListNew) {
        setState(() {
          noteList = noteListNew;
          count = noteListNew.length;
        });
      });
    });
  }

  // Store Data
  void _createNote(NoteModel noteModel) async {
    int result = await dbHelper.create(noteModel);
    if (result > 0) {
      _updateListView();
    }
  }

  // Update Data
  void _updateNote(NoteModel noteModel) async {
    int result = await dbHelper.update(noteModel);
    if (result > 0) {
      _updateListView();
    }
  }

  // Delete Data
  void _deleteNote(NoteModel noteModel) async {
    int result = await dbHelper.delete(noteModel.id!);
    if (result > 0) {
      _updateListView();
    }
  }

  @override
  void initState() {
    super.initState();
    regisNotification();
    checkMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _createOrUpdate();
          },
          backgroundColor: Colors.lightBlue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('To Do List Page'),
              GestureDetector(
                onTap: () async {
                  await authService.signOut();
                },
                child: const Icon(Icons.logout),
              )
            ],
          ),
          backgroundColor: Colors.lightBlue,
          automaticallyImplyLeading: false,
        ),
        body: Center(
            child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text("Total Notifikasi: ${_totalNotification.toString()}"),
            const SizedBox(
              height: 40,
            ),
            if (count == 0) const Text('Kosong Icibos'),
            createNoteListView(),
          ],
        )));
  }
}
