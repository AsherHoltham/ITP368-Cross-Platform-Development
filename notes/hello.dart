import 'dart:io'; // for 'stdout'
import 'dart:math'; // for sqrt in isPrime()

void main()
{
  // output
  print("hi there");

  // variable, output variable
  int x = 5;
  print("x=$x"); // print("x="+x.toString());

  // there are no primitives.  everything is an object.

  // auto typing.
  var weight = 82.3; // Kg
  print('weight=$weight');

  // lists are easy, are Dart's arrays.
  var friends = ['Bob', 'Jane', 'Alice'];
  print('friends=$friends');
  print('friend[1]=${friends[1]}'); // braces for anything complex

  // maps are easy too
  var favoriteNumbers = {'Bob': 5, "Jane": 3.14};
  print("favoriteNumbers=$favoriteNumbers");
  print("Bob's is ${favoriteNumbers['Bob']}");

  // 'if's as like C++ or Java
  if (weight > 80)
  { print('heavy\n'); }
  else
  { print('light\n');
  }

  // built in 'for' loop for lists, or do counting
  for (var name in friends)
  { for (int i = 0; i < 3; i++)
    { print("I like $name.");
    }
  }

  // 'while' loop like C++/Java
  // note: write without newline
  while (x > 0) {
    stdout.write("$x ");
    x--;
  }
  print("");

  // print primes to 20, function call to isPrime()
  for (int j = 2; j < 20; j++) {
    if (isPrime(j)) {
      print("$j is prime");
    }
  }

  // sort numbers to 20 mod 5
  List<int> nums = []; // explicit typing when needed
  for (int j = 2; j < 20; j++) {
    nums.add(j);
  }
  /* sort( function(a,b) ).  Defined here anonymously.
     => arrow is shorthand
  */
  nums.sort((a, b) => (a % 5 - b % 5));
  print(nums);
}

// isp return true iff n is prime
bool isPrime(int n)
{ var isp = true;
  int lim = sqrt(n).toInt();
  for (int i = 2; isp && i <= lim; i++)
  { if (n % i == 0)
    { isp = false;
    }
  }
  return isp;
}
