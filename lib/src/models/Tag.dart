class Tag {
  String tag;
  num count;

  Tag(this.tag, this.count);

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(json['tag'], json['count']);
  }

  Map<String, dynamic> toMap() {
    return {
      'tag': tag,
      'count': count,
    };
  }
}
