import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteView extends StatelessWidget {
  String title;
  String description;
  String createdOn;
  String modifiedOn;
  NoteView(this.title, this.description, this.createdOn, this.modifiedOn);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
      ),
      body: LayoutBuilder(builder: (context, constrained) {
        return SingleChildScrollView(
          child: Container(
            height: constrained.maxHeight,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    child: Text(
                  description,
                )),
                Spacer(),
                Text(
                  'Created On:-  ' +
                      DateFormat.yMd()
                          .add_jm()
                          .format(DateTime.parse(createdOn)),
                ),
                if (modifiedOn != '')
                  Text(
                    'Modified On' +
                        DateFormat.yMd()
                            .add_jm()
                            .format(DateTime.parse(modifiedOn)),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
