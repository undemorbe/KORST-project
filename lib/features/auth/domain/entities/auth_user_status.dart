enum AuthUserStatus { notFound, notRegistered, user, admin }

extension AuthUserStatusX on AuthUserStatus {
  static AuthUserStatus fromApi(String? value) {
    switch (value) {
      case 'notFound':
        return AuthUserStatus.notFound;
      case 'notRegistered':
        return AuthUserStatus.notRegistered;
      case 'user':
      case 'registered':
        return AuthUserStatus.user;
      case 'admin':
        return AuthUserStatus.admin;
      default:
        return AuthUserStatus.notFound;
    }
  }
}
