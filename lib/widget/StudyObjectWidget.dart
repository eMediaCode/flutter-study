import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_study/model/StudyObject.dart';

typedef MyCallback(StudyObject studyObject);

class StudyObjectWidget extends StatelessWidget {
  const StudyObjectWidget({
    Key key,
    @required this.studyObject,
    @required this.onDelete,
    @required this.onUpdate,
  })
      : assert(studyObject != null),
        assert(onDelete != null),
        assert(onUpdate != null),
        super(key: key);

  final StudyObject studyObject;
  final MyCallback onDelete;
  final MyCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = Theme.of(context).dividerColor;

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
        title: new Text(studyObject.name ?? ''),
        subtitle: new Text(studyObject.description ?? ''),
        trailing: new Row(
          children: <Widget>[
            new IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onUpdate(studyObject),
            ),
            new IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDelete(studyObject),
            ),
          ],
        ),
      ),
    );
  }
}
