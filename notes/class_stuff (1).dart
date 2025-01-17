import "dart:io";

void main() 
{
  print("class stuff");

  BankAccount a = BankAccount(234);
  a.report();

  BankAccount b = BankAccount(123, balance: 44.78);
  b.report();
  b.balance += 100;
  b.report();
  b.xfer(-5.0);
  b.report();

  // works in terminal:
  // > dart class_stuff.dart
  /*
  print("How much to add?" );
  String? val = stdin.readLineSync(); 
  if (val != null )
  {
    // String val = "1000.0";
    print("read: ${val}");
    double v = double.parse(val);
    print("adding $v");
    b.xfer(v);
    b.report();
  }
  */

  print("peeps=");
  var peeps = ['Barry', 'Frank', 'Bob', 'Betty', 'Hal', 'Mike'];
  peeps.where((name) => name[0] == "B").forEach(print);
  print("more peeps=");
  var morePeeps = ["Beth", "Belle", ...peeps, "Brad"];
  morePeeps.forEach(print);
}

class SomeClass
{
  int a;

  SomeClass(this.a);
  // SomeClass.second(); // not allowed, must init a
  //SomeClass.third({this.a}); // not allowed because named
  // parameters can be missing, which means a can be null
  SomeClass.fourth({required this.a});
  SomeClass.fifth({this.a = 0});
  SomeClass.sixth(int newa) : a = newa;
  // SomeClass.seventh(int newa)
  // {  a = newa; } // not allowed, a= is too late
}

class BankAccount
{
  var balance; // type is 'dynamic'
  final int id; // cannot change it once set
  double? lastTransaction; // ? means might not have a value,
  // ie "nullable"
  late int b;

  BankAccount(this.id, {this.balance = 0});
  // braces mean named parameter.

  // prints a message if the last transaction was >1000
  // will not compile without the "!"
  // As is, lastTransaction must be set before calling this.
  void tooMuch()
  {
    if (lastTransaction! > 1000)
    {
      print("that was a lot.");
    }
  }

  // works if null because toString() just does ""
  void showLastTransaction()
  {
    print("last=" + lastTransaction.toString());
  }

  void xfer(double amt)
  {
    lastTransaction = amt;
    balance += amt;
  }

  report()
  {
    print("act $id has \$$balance");
    if (lastTransaction != null)
    {
      print("last=$lastTransaction");
    }
    else
    {
      print("last not defined");
    }
  }
}

enum MenuType { hotDog, hamburger, salad }

class CheckingAccount extends BankAccount
{
  int checkCount = 0; // number of checks written

  CheckingAccount(id) : super(id);
}

class Pet
{
  String name;
  Pet(this.name);
}

class Dog extends Pet
{
  Dog(super.name);
}
