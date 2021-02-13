import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/screen/add_note_screen.dart';
import '../../screen/note_view.dart';

class Notes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uid = FirebaseAuth.instance.currentUser.uid;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users/$uid/notes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List doc = snapshot.data.documents;

          return doc.isEmpty
              ? Center(
                  child: Text(
                  "No Notes Available",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ))
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) => Dismissible(
                    key: ValueKey(doc[index].id),
                    background: Container(
                      color: Theme.of(context).errorColor,
                      child: Icon(
                        Icons.delete,
                        size: 35,
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) {
                      return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: Text(
                                  'Are you sure?',
                                ),
                                content:
                                    Text('Do you want to delete this item?'),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(false);
                                      },
                                      child: Text('No')),
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(true);
                                      },
                                      child: Text('Yes'))
                                ],
                              ));
                    },
                    onDismissed: (_) {
                      doc[index].delete();
                    },
                    child: ListTile(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => NoteView(
                                doc[index]['title'],
                                doc[index]['description'],
                                doc[index]['createdOn'],
                                doc[index]['editOn'],
                              ))),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(doc[index]['imageUrl']),
                      ),
                      title: Text(doc[index]['title']),
                      subtitle: Text('Created on:-' +
                          DateFormat.yMd()
                              .add_jm()
                              .format(DateTime.parse(doc[index]['createdOn']))),

                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AddNoteScreen.routeName, arguments: {
                          'id': doc[index].id,
                          'title': doc[index]['title'],
                          'createdOn': doc[index]['createdOn'],
                          'description': doc[index]['description'],
                          'imageUrl': doc[index]['imageUrl'],
                          'editOn': doc[index]['editOn'],
                          'reminderDate': doc[index]['reminderDate'],
                          'reminderTime': doc[index]['reminderTime'],
                        }),
                      ),
                      // ,
                      // doc[index]['userId'] == uid,
                      // doc[index]['userName'],
                      // doc[index]['userImage']),
                    ),
                  ),
                  //    itemBuilder: (context, index) => doc[index],
                );
        });
  }
}
