
/**
Write a program to explore the following function of one integer.

f(x) = 3x+1 if x is odd
       x/2 if x is even

The idea is to repeat x = f(x) and get a sequence of values.
The sequence will end in 1 (not proven, but it will).  

Let's make a class that holds the sequence, the max of the
sequence, and the length of the sequence.  

Make a function that returns a sequence as a list.  We will also
need functions that get the max and the length, but we may be
able to find these (as functions of a list).  

Now we can explore what happens with various starting numbers,
between 1 an 100, say.  

Try printing the maximum value of the sequence for each number
between 1 and 100.

Now try printing the length of the sequence (for each starting
number between 1 an 100).  

One goal here is the try to initialize the class in the constructor.
We would like the member variables to be 'final'.  

Submit as ThreexYourName.dart .  Mine would be ThreexKosterB.dart .
*/
class CollatzConjecture {
  var sequence = []; // could not make member variables "final with my implementation"
  var max;
  var length;

  CollatzConjecture(int start_of_sequence) {
    int x = start_of_sequence;
    while(x != 1){
      sequence.add(x);
      x = f(x);
    }
    sequence.add(x);
    this.max = this.sequence.reduce((val, i) => val > i ? val : i);
    this.length = this.sequence.length;
  }

  List<int> produce(int x){
    List<int> sequence = [];
    while(x != 1){
      sequence.add(x);
      x = f(x);
    }
    sequence.add(x);
    return sequence;
  }

  int f(int x){
    if(x % 2 == 0) return (x ~/ 2);
    return (3 * x + 1);
  }
}

void main() {
  for (int i = 1; i <= 100; i++){
    CollatzConjecture index_sequence = CollatzConjecture(i);
    print("${i}: Max: ${index_sequence.max}, length: ${index_sequence.length}");
  }
}