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

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<NoteModel> noteList = [];
  int count = 0;

  // int _totalNotification = 0;
  String test = "Hai";
  PushNotif? _notifInfo;

  void regisNotification() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
        PushNotif pushNotif = PushNotif(
          title: remoteMessage.notification?.title,
          body: remoteMessage.notification?.body,
          dataTitle: remoteMessage.data['title'],
          dataBody: remoteMessage.data['body'],
        );

        setState(() {
          test = " Ganti";
          _notifInfo = pushNotif;
          // _totalNotification++;
        });

        if (_notifInfo != null) {
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
        // _totalNotification++;
      });
    }
  }

  // Modal Bottom Sheet
  Future<void> _createOrUpdate({NoteModel? noteModel, int? index}) async {
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
                      if (_titleController.text.isEmpty ||
                          _descriptionController.text.isEmpty) return;
                      if (action == 'create') {
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
                        _updateNote(noteModel, index!);
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
  Widget createNoteListView() {
    return AnimatedList(
      key: listKey,
      initialItemCount: noteList.length,
      itemBuilder: (context, index, animation) {
        return slideIt(context, index, animation);
      },
    );
  }

  // Fetch Data From SQFLite
  Future<void> _updateListView() async {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<NoteModel>> noteListFuture = dbHelper.getAllData();
      noteListFuture.then((noteListNew) async {
        for (int item = 0; item < noteListNew.length; item++) {
          // 1) Wait for one second
          await Future.delayed(const Duration(milliseconds: 400));
          // 2) Adding data to actual variable that holds the item.
          noteList.add(noteListNew[item]);
          // 3) Telling animated list to start animation
          listKey.currentState?.insertItem(noteList.length - 1);
        }
      });
    });
  }

  Widget slideIt(BuildContext context, int index, animation) {
    // NoteModel item = noteList[index];
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        key: UniqueKey(),
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Card(
            elevation: 0,
            color: Colors.grey.shade200,
            child: ListTile(
              title: Text(noteList[index].title!),
              subtitle: Text(noteList[index].description!),
              trailing: GestureDetector(
                child: const Icon(Icons.delete),
                onTap: () {
                  _deleteNote(noteList[index], index);
                },
              ),
              onTap: () async {
                _createOrUpdate(noteModel: noteList[index], index: index);
              },
            ),
          ),
        ),
      ),
    );
  }

  // Store Data
  void _createNote(NoteModel noteModel) async {
    int result = await dbHelper.create(noteModel);
    if (result > 0) {
      noteModel.id = result;

      listKey.currentState
          ?.insertItem(0, duration: const Duration(milliseconds: 500));
      noteList = []
        // ignore: prefer_inlined_adds
        ..add(noteModel)
        ..addAll(noteList);
    }
  }

  // Update Data
  void _updateNote(NoteModel noteModel, int index) async {
    int result = await dbHelper.update(noteModel);
    if (result > 0) {
      // _updateListView();
      setState(() {
        noteList[index] = noteModel;
      });
    }
  }

  // Delete Data
  void _deleteNote(NoteModel noteModel, int index) async {
    int result = await dbHelper.delete(noteModel.id!);
    if (result > 0) {
      // _updateListView();
      listKey.currentState?.removeItem(
          index, (_, animation) => slideIt(context, 0, animation),
          duration: const Duration(milliseconds: 500));
      noteList.removeAt(index);
    }
  }

  @override
  void initState() {
    super.initState();
    regisNotification();
    checkMessage();
    _updateListView();
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
              child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              // if (count == 0) const Text('Kosong Icibos'),
              Expanded(child: createNoteListView())
            ],
          )),
        ));
  }
}
