class StudyObject {
  final String key;
  String name;
  String description;

  StudyObject(this.key);

  StudyObject.fromJson(this.key, Map data)
      : name = data['name'],
        description = data['description'];

  @override
  String toString() {
    return {'key': key, 'name': name, 'description': description}.toString();
  }
}
