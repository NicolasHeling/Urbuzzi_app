enum UserRole {
  administrador,
  gestor,
  comercial,
  consulta;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'administrador':
        return UserRole.administrador;
      case 'gestor':
        return UserRole.gestor;
      case 'comercial':
        return UserRole.comercial;
      default:
        return UserRole.consulta;
    }
  }

  String get label {
    switch (this) {
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.gestor:
        return 'Gestor';
      case UserRole.comercial:
        return 'Comercial';
      case UserRole.consulta:
        return 'Consulta';
    }
  }

  bool get canWrite => this == UserRole.administrador || this == UserRole.gestor || this == UserRole.comercial;
  bool get canApprove => this == UserRole.administrador || this == UserRole.gestor;
}
