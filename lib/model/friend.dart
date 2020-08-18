class Friend {
  String name;
  String level;
  String avatar;

  Friend(name, level, avatar) {
    this.name = name;
    this.level = level;
    this.avatar = avatar;
  }

  String getName() {
    return this.name;
  }

  void setName(String name) {
    this.name = name;
  }

  String getLevel() {
    return this.level;
  }

  void setLevel(String level) {
    this.level = level;
  }

  String getAvatar() {
    return this.avatar;
  }

  void setAvatar(String avatar) {
    this.avatar = avatar;
  }
}