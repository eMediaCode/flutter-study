import 'package:flutter/material.dart';
import 'package:flutter_study/model/StudyObject.dart';

class StudyObjectWidget extends StatelessWidget {
  StudyObjectWidget(this.studyObject, this.onDelete, this.onUpdate);

  final StudyObject studyObject;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = Theme.of(context).dividerColor;

    String name = studyObject.name;
    if (name == null) name = '';

    String description = studyObject.description;
    if (description == null) description = '';

    return new DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            color: dividerColor,
            width: 0.0,
          ),
        ),
      ),
      child: new ListTile(
        leading: new Icon(Icons.all_inclusive),
        title: new Text(name),
        subtitle: new Text(description),
        trailing: new Row(
          children: <Widget>[
            new IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onUpdate,
            ),
            new IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
