
/**
Make a program to demo the Horse class

The Horse class has horse's 
  name - string
  age - years
  sex - m or f (also a string)
  number of wins
  number of 2nd place
  rating - = (# of wins x 2 + @ of 2nd place) / (years - 1)

The Horse class constructor should take the 1st 5 as 
arguments and generate the 6th during initialization.

Text it with a couple ...

Bob, 4, m, 5, 7
Jane, 3, f, 6, 2
*/

void main() {
    Horse bob = Horse('Bob', 10, 'm', 5, 7);
    Horse jane = Horse('Jane', 15, 'f', 6, 2);
    bob.output();
    jane.output();
}

class Horse {
    var name;
    var age;
    var sex;
    var first_place;
    var second_place;
    var rating;

    Horse(this.name, this.age, this.sex, this.first_place, this.second_place){
        this.rating = (2 * this.first_place + this.second_place) / (this.age + 1);
    }

    void output() {
        print("Age: ${this.age}\r\nName: ${this.name}\r\nSex: ${this.sex}\r\nRating: ${this.rating.toStringAsPrecision(3)}");
    }
}