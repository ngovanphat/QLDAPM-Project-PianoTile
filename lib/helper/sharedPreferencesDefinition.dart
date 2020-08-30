class sharedPrefKeys {
  static String userType = "userType";

  static String getRoomIdKey() {
    return "roomId";
  }

  static String getIsRoomHostKey() {
    return "isRoomHost";
  }

  static String getIdKey() {
    return (userType == sharedPrefValues.GUEST) ? "guestId" : "userId";
  }

  static String getNameKey() {
    return (userType == sharedPrefValues.GUEST) ? "guestName" : "userName";
  }

  static String getExpKey() {
    return (userType == sharedPrefValues.GUEST) ? "guestExp" : "userExp";
  }

  static String getGemKey() {
    return (userType == sharedPrefValues.GUEST) ? "guestGem" : "userGem";
  }

  static String getNextExpKey() {
    return (userType == sharedPrefValues.GUEST)
        ? "guestNextExp"
        : "userNextExp";
  }

  static String getLevelKey() {
    return (userType == sharedPrefValues.GUEST) ? "guestLevel" : "userLevel";
  }
}

class sharedPrefValues {
  // user type
  static int GUEST = 0;
  static int USER = 1;
}
