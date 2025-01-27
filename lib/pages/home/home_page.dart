import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_taptime/models/user_model.dart';
import 'package:flutter_taptime/services/auth_service.dart';

class HomePage extends StatefulWidget {
  final UserModel? userModel;
  const HomePage({super.key, this.userModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final CollectionReference _studentAttendance =
      FirebaseFirestore.instance.collection('attendance');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _statusController.text = documentSnapshot['status'];
    }

    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nama Siswa"),
                ),
                TextField(
                  controller: _statusController,
                  decoration: const InputDecoration(labelText: "Status Siswa"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text.trim();
                      final String status = _statusController.text.trim();
                      if (name.isNotEmpty && status.isNotEmpty) {
                        if (action == 'create') {
                          await _studentAttendance
                              .add({"name": name, "status": status});
                        }
                        if (action == 'update') {
                          await _studentAttendance
                              .doc(documentSnapshot!.id)
                              .update({"name": name, "status": status});
                        }

                        _nameController.clear();
                        _statusController.clear();

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text(action == 'create' ? 'Simpan' : 'Ubah')),
              ],
            ),
          );
        });
  }

  Future<void> _deleteAttendance(String attendanceId) async {
    final messenger = ScaffoldMessenger.of(context);

    await _studentAttendance.doc(attendanceId).delete();

    messenger.showSnackBar(const SnackBar(
      content: Text("Data berhasil dihapus"),
      backgroundColor: Colors.lightBlue,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Home Page'),
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
      body: StreamBuilder(
          stream: _studentAttendance.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              if (streamSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Data tidak ditemukan'));
              }
              return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      color: Colors.white,
                      child: ListTile(
                        title: Text(documentSnapshot['name']),
                        subtitle: Text(documentSnapshot['status']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _createOrUpdate(documentSnapshot);
                                  },
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    _deleteAttendance(documentSnapshot.id);
                                  },
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _nameController.clear();
          _statusController.clear();
          _createOrUpdate();
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
