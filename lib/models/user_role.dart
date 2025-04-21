enum UserRole {
  admin('Admin'),
  projectDirector('Project Director'),
  salesDirector('Sales Director'),
  marketingDirector('Marketing Director'),
  receptionist('Receptionist'),
  salesperson('Salesperson'),
  designer('Designer'),
  productionManager('Production Manager'),
  printingManager('Printing Manager'),
  accountant('Accountant'),
  labor('Labor'),
  driver('Driver');

  final String displayName;
  const UserRole(this.displayName);

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == role,
      orElse: () => UserRole.receptionist,
    );
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isDirector => [
        UserRole.projectDirector,
        UserRole.salesDirector,
        UserRole.marketingDirector,
      ].contains(this);
  bool get isManager => [
        UserRole.productionManager,
        UserRole.printingManager,
      ].contains(this);
  bool get isStaff => [
        UserRole.receptionist,
        UserRole.salesperson,
        UserRole.designer,
        UserRole.accountant,
        UserRole.labor,
        UserRole.driver,
      ].contains(this);
}
